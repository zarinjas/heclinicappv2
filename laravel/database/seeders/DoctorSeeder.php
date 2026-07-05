<?php

namespace Database\Seeders;

use App\Models\Branch;
use App\Models\Doctor;
use Illuminate\Database\Seeder;

class DoctorSeeder extends Seeder
{
    public function run(): void
    {
        $shahAlam = Branch::where('plato_facility_id', 'FAC-SA-001')->first();
        $bangi = Branch::where('plato_facility_id', 'FAC-BNG-001')->first();

        $doctors = [
            [
                'branch_id' => $shahAlam?->id,
                'name' => 'Dr. Ahmad bin Ibrahim',
                'specialty' => 'General Practitioner',
                'bio' => 'Dr. Ahmad has over 15 years of experience in primary care and family medicine. He is dedicated to providing comprehensive healthcare to patients of all ages.',
                'plato_facility_id' => 'DOC-AHMAD-001',
                'is_visible_in_app' => true,
                'is_active' => true,
            ],
            [
                'branch_id' => $shahAlam?->id,
                'name' => 'Dr. Siti Nurhaliza binti Mohamed',
                'specialty' => 'Family Medicine Specialist',
                'bio' => 'Dr. Siti specializes in family medicine with focus on women\'s health and chronic disease management. She believes in holistic patient-centered care.',
                'plato_facility_id' => 'DOC-SITI-001',
                'is_visible_in_app' => true,
                'is_active' => true,
            ],
            [
                'branch_id' => $bangi?->id,
                'name' => 'Dr. Rajesh a/l Muthusamy',
                'specialty' => 'General Practitioner',
                'bio' => 'Dr. Rajesh provides comprehensive primary care services with special interest in sports medicine and adolescent health.',
                'plato_facility_id' => 'DOC-RAJESH-001',
                'is_visible_in_app' => false,
                'is_active' => true,
            ],
        ];

        foreach ($doctors as $doctor) {
            if ($doctor['branch_id']) {
                Doctor::firstOrCreate(
                    ['plato_facility_id' => $doctor['plato_facility_id']],
                    $doctor,
                );
            }
        }
    }
}
