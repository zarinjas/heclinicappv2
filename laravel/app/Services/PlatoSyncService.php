<?php

namespace App\Services;

use App\Models\Branch;
use App\Models\Doctor;
use Illuminate\Support\Facades\Log;

final class PlatoSyncService
{
    private PlatoProxyService $proxy;

    public function __construct(PlatoProxyService $proxy)
    {
        $this->proxy = $proxy;
    }

    /**
     * Sync branches (locations), doctors (providers) and doctor->branch
     * assignments (calendars) from Plato's GET /systemsetup.
     *
     * Plato is the source of truth for: names, addresses, specialities, and
     * doctor-branch assignment. Admin-managed fields (image, photo, bio,
     * whatsapp_number, operating_hours, visibility toggles) are never
     * overwritten by the sync.
     */
    public function syncAll(): array
    {
        $result = $this->proxy->proxy('GET', '/systemsetup');

        if (! empty($result['error'])) {
            $this->logError($result);

            return [
                'success' => false,
                'message' => 'Failed to fetch data from Plato: '.($result['message'] ?? 'Unknown error'),
                'branches_created' => 0,
                'branches_updated' => 0,
                'doctors_created' => 0,
                'doctors_updated' => 0,
            ];
        }

        $data = $result['data'] ?? [];

        $locations = $this->extractLocations($data);
        $providers = $this->extractProviders($data);
        $calendars = $this->extractCalendars($data);

        $branchStats = $this->syncBranches($locations);
        $doctorStats = $this->syncDoctors($providers, $calendars);

        $total = array_sum([...array_values($branchStats), ...array_values($doctorStats)]);

        return [
            'success' => true,
            'message' => 'Plato sync complete. '.$total.' record'.($total !== 1 ? 's' : '').' processed.',
            'branches_created' => $branchStats['created'],
            'branches_updated' => $branchStats['updated'],
            'doctors_created' => $doctorStats['created'],
            'doctors_updated' => $doctorStats['updated'],
        ];
    }

    private function syncBranches(array $locations): array
    {
        $created = 0;
        $updated = 0;

        foreach ($locations as $location) {
            $facilityId = $location['given_id'] ?? null;

            if ($facilityId === null || $facilityId === '') {
                continue;
            }

            $print = $location['print'] ?? [];
            $name = $print['header'] ?? $location['name'] ?? $facilityId;
            $address = $this->buildAddress($print);

            $branch = Branch::where('plato_facility_id', $facilityId)->first();

            if ($branch === null) {
                Branch::create([
                    'name' => $name,
                    'address' => $address,
                    'plato_facility_id' => $facilityId,
                    'is_active' => true,
                    'is_visible_in_app' => true,
                ]);
                $created++;

                continue;
            }

            // Only sync Plato-owned fields. Never touch admin-managed fields.
            $syncFields = [];

            if ($name !== '' && $branch->name !== $name) {
                $syncFields['name'] = $name;
            }
            if ($address !== null && $branch->address !== $address) {
                $syncFields['address'] = $address;
            }

            if (! empty($syncFields)) {
                $branch->update($syncFields);
                $updated++;
            }
        }

        return ['created' => $created, 'updated' => $updated];
    }

    private function syncDoctors(array $providers, array $calendars): array
    {
        // Map doctor given_id -> branch_id using calendar cross-references.
        $branchIdByFacility = Branch::pluck('id', 'plato_facility_id')->toArray();
        $branchIdByDoctorGivenId = $this->mapDoctorToBranch($calendars, $branchIdByFacility);

        $created = 0;
        $updated = 0;

        foreach ($providers as $provider) {
            $facilityId = $provider['given_id'] ?? null;

            if ($facilityId === null || $facilityId === '') {
                continue;
            }

            $name = $provider['name'] ?? $facilityId;
            $specialty = $provider['qual'] ?? null;
            $branchId = $branchIdByDoctorGivenId[$facilityId] ?? null;

            $doctor = Doctor::where('plato_facility_id', $facilityId)->first();

            if ($doctor === null) {
                // Doctors require a branch assignment. Skip providers that
                // Plato calendars don't map to any location yet.
                if ($branchId === null) {
                    continue;
                }

                Doctor::create([
                    'name' => $name,
                    'specialty' => $specialty,
                    'branch_id' => $branchId,
                    'plato_facility_id' => $facilityId,
                    'is_active' => true,
                    'is_visible_in_app' => false,
                ]);
                $created++;

                continue;
            }

            $syncFields = [];

            if ($name !== '' && $doctor->name !== $name) {
                $syncFields['name'] = $name;
            }
            if ($specialty !== null && $doctor->specialty !== $specialty) {
                $syncFields['specialty'] = $specialty;
            }
            if ($branchId !== null && $doctor->branch_id !== $branchId) {
                $syncFields['branch_id'] = $branchId;
            }

            if (! empty($syncFields)) {
                $doctor->update($syncFields);
                $updated++;
            }
        }

        return ['created' => $created, 'updated' => $updated];
    }

    /**
     * Build a doctor given_id -> branch_id map from Plato calendars.
     */
    private function mapDoctorToBranch(array $calendars, array $branchIdByFacility): array
    {
        $map = [];

        foreach ($calendars as $calendar) {
            $doctorGivenId = $calendar['doctor'] ?? null;
            $locationGivenId = $calendar['location'] ?? null;

            if ($doctorGivenId === null || $doctorGivenId === '' || $locationGivenId === null || $locationGivenId === '') {
                continue;
            }

            if (isset($branchIdByFacility[$locationGivenId]) && ! isset($map[$doctorGivenId])) {
                $map[$doctorGivenId] = $branchIdByFacility[$locationGivenId];
            }
        }

        return $map;
    }

    private function buildAddress(array $print): ?string
    {
        $parts = array_filter([
            $print['address'] ?? null,
            $print['address2'] ?? null,
            $print['address3'] ?? null,
        ]);

        if (empty($parts)) {
            return null;
        }

        return implode(', ', $parts);
    }

    private function extractLocations(array $data): array
    {
        return $data['locations'] ?? [];
    }

    private function extractProviders(array $data): array
    {
        return $data['providers'] ?? [];
    }

    private function extractCalendars(array $data): array
    {
        return $data['calendars'] ?? [];
    }

    private function logError(array $result): void
    {
        Log::channel('plato')->error('Plato sync failed', [
            'code' => $result['code'] ?? 'unknown',
            'message' => $result['message'] ?? 'Unknown error',
        ]);
    }
}
