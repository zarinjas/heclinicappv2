<?php

namespace Database\Seeders;

use App\Models\Branch;
use Illuminate\Database\Seeder;

class BranchSeeder extends Seeder
{
    public function run(): void
    {
        $branches = [
            [
                'name' => 'He Clinic Shah Alam',
                'address' => 'No. 12, Jalan Plumbum P7/P, Seksyen 7, 40000 Shah Alam, Selangor',
                'phone' => '+603-5510 1234',
                'whatsapp_number' => '+60123456789',
                'operating_hours' => [
                    'monday' => '08:00-17:00',
                    'tuesday' => '08:00-17:00',
                    'wednesday' => '08:00-17:00',
                    'thursday' => '08:00-17:00',
                    'friday' => '08:00-17:00',
                    'saturday' => '08:00-13:00',
                ],
                'plato_facility_id' => 'FAC-SA-001',
                'is_active' => true,
            ],
            [
                'name' => 'He Clinic Bangi',
                'address' => 'No. 45, Jalan Medan Pusat Bandar 2, Seksyen 9, 43650 Bandar Baru Bangi, Selangor',
                'phone' => '+603-8920 5678',
                'whatsapp_number' => '+60198765432',
                'operating_hours' => [
                    'monday' => '08:30-17:30',
                    'tuesday' => '08:30-17:30',
                    'wednesday' => '08:30-17:30',
                    'thursday' => '08:30-17:30',
                    'friday' => '08:30-17:30',
                    'saturday' => '08:30-13:00',
                ],
                'plato_facility_id' => 'FAC-BNG-001',
                'is_active' => true,
            ],
            [
                'name' => 'He Clinic Putrajaya',
                'address' => 'Lot 3-15, Jalan P15H, Presint 15, 62000 Putrajaya',
                'phone' => '+603-8880 9012',
                'whatsapp_number' => '+60111234567',
                'operating_hours' => [
                    'monday' => '08:00-17:00',
                    'tuesday' => '08:00-17:00',
                    'wednesday' => '08:00-17:00',
                    'thursday' => '08:00-17:00',
                    'friday' => '08:00-12:30',
                ],
                'plato_facility_id' => 'FAC-PTJ-001',
                'is_active' => false,
            ],
        ];

        foreach ($branches as $branch) {
            Branch::firstOrCreate(
                ['plato_facility_id' => $branch['plato_facility_id']],
                $branch,
            );
        }
    }
}
