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
                'operating_hours' => 'Mon-Fri: 8:00 AM - 5:00 PM, Sat: 8:00 AM - 1:00 PM',
                'plato_facility_id' => 'FAC-SA-001',
                'is_active' => true,
            ],
            [
                'name' => 'He Clinic Bangi',
                'address' => 'No. 45, Jalan Medan Pusat Bandar 2, Seksyen 9, 43650 Bandar Baru Bangi, Selangor',
                'phone' => '+603-8920 5678',
                'whatsapp_number' => '+60198765432',
                'operating_hours' => 'Mon-Fri: 8:30 AM - 5:30 PM, Sat: 8:30 AM - 1:00 PM',
                'plato_facility_id' => 'FAC-BNG-001',
                'is_active' => true,
            ],
            [
                'name' => 'He Clinic Putrajaya',
                'address' => 'Lot 3-15, Jalan P15H, Presint 15, 62000 Putrajaya',
                'phone' => '+603-8880 9012',
                'whatsapp_number' => '+60111234567',
                'operating_hours' => 'Mon-Thu: 8:00 AM - 5:00 PM, Fri: 8:00 AM - 12:30 PM',
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
