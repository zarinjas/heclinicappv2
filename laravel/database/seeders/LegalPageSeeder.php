<?php

namespace Database\Seeders;

use App\Models\CmsLegalPage;
use Illuminate\Database\Seeder;

class LegalPageSeeder extends Seeder
{
    public function run(): void
    {
        CmsLegalPage::updateOrCreate(
            ['slug' => 'privacy'],
            [
                'title' => 'Privacy Policy',
                'last_updated' => '2026-07-01',
                'is_active' => true,
                'sections' => $this->privacySections(),
            ],
        );

        CmsLegalPage::updateOrCreate(
            ['slug' => 'terms'],
            [
                'title' => 'Terms of Service',
                'last_updated' => '2026-07-01',
                'is_active' => true,
                'sections' => $this->termsSections(),
            ],
        );
    }

    private function privacySections(): array
    {
        return [
            [
                'heading' => 'Introduction',
                'body' => 'He Medical Clinic ("we", "our", "us") is committed to protecting the privacy of every patient. This Privacy Policy explains how we collect, use, disclose and safeguard your personal information when you use the He Medical Clinic mobile application and our services.',
            ],
            [
                'heading' => 'Information We Collect',
                'body' => 'We collect personal information that you provide to us when registering for an account, booking an appointment, or updating your profile. This includes your full name, NRIC or passport number, contact details, date of birth, and medical history relevant to the care you receive at He Medical Clinic. We may also collect device information and usage data when you interact with the app.',
            ],
            [
                'heading' => 'How We Use Your Information',
                'body' => 'Your information is used to manage appointments, process registrations and payments, communicate important updates and reminders, deliver the healthcare services you request, and improve the quality of our services. With your consent, we may also send you relevant health information.',
            ],
            [
                'heading' => 'Data Storage & Security',
                'body' => 'We implement appropriate technical and organisational measures to protect your personal data against unauthorised access, alteration, disclosure or destruction. Your data is stored securely on servers located within Malaysia and access is restricted to authorised personnel who require it to deliver your care.',
            ],
            [
                'heading' => 'Sharing Your Information',
                'body' => 'We do not sell your personal information. We may share your data with healthcare providers as necessary for your treatment, with regulatory bodies as required by law, and with service providers who assist in our operations under strict confidentiality agreements.',
            ],
            [
                'heading' => 'Your Rights',
                'body' => 'You have the right to access, correct, or request deletion of your personal data. You may also withdraw consent for certain data processing activities. To exercise these rights, please contact us using the details below.',
            ],
            [
                'heading' => 'Retention',
                'body' => 'We retain your personal information for as long as necessary to provide our services and to comply with legal, regulatory and medical record-keeping obligations. When data is no longer required, it is securely deleted or anonymised.',
            ],
            [
                'heading' => 'Policy Updates',
                'body' => 'We may update this Privacy Policy from time to time. We will notify you of any significant changes through the app or by other appropriate means. Continued use of the app after such changes constitutes acceptance of the updated policy.',
            ],
            [
                'heading' => 'Contact Us',
                'body' => 'If you have any questions about this Privacy Policy or how your data is handled, please contact us at admin@hemedclinic.com or visit any of our clinics.',
            ],
        ];
    }

    private function termsSections(): array
    {
        return [
            [
                'heading' => 'Agreement',
                'body' => 'By downloading, installing, or using the He Medical Clinic mobile application, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the application.',
            ],
            [
                'heading' => 'The Service',
                'body' => 'He Medical Clinic provides a mobile application for managing personal healthcare appointments, viewing medical records and documents, and communicating with the clinic. The information provided through the app is for convenience and does not replace professional medical advice.',
            ],
            [
                'heading' => 'License',
                'body' => 'We grant you a limited, non-exclusive, non-transferable, revocable license to use the application for your personal, non-commercial healthcare management. You may not modify, distribute, reverse engineer, or create derivative works based on the application.',
            ],
            [
                'heading' => 'Account Responsibility',
                'body' => 'You are responsible for maintaining the confidentiality of your account credentials and for all activities that occur under your account. You agree to provide accurate information and to notify us immediately of any unauthorised use of your account.',
            ],
            [
                'heading' => 'Medical Disclaimer',
                'body' => 'Content within the application is provided for general information only and is not a substitute for professional medical advice, diagnosis, or treatment. Always seek the advice of a qualified healthcare provider with any questions you may have regarding a medical condition. In an emergency, contact your nearest hospital or emergency services.',
            ],
            [
                'heading' => 'Service Changes',
                'body' => 'We reserve the right to modify, suspend, or discontinue any part of the service at any time, with or without notice. We are not liable for any damages arising from the use or inability to use the service.',
            ],
            [
                'heading' => 'Disclaimer of Warranties',
                'body' => 'The service is provided on an "as is" and "as available" basis. To the fullest extent permitted by law, He Medical Clinic disclaims all warranties, express or implied, including warranties of merchantability, fitness for a particular purpose, and non-infringement.',
            ],
            [
                'heading' => 'Limitation of Liability',
                'body' => 'To the fullest extent permitted by law, He Medical Clinic, its directors, officers, employees, and agents shall not be liable for any indirect, incidental, special, consequential, or punitive damages arising out of or related to your use of the service.',
            ],
            [
                'heading' => 'Governing Law',
                'body' => 'These terms are governed by the laws of Malaysia. Any disputes arising under these terms shall be subject to the exclusive jurisdiction of the courts of Malaysia.',
            ],
            [
                'heading' => 'Contact Us',
                'body' => 'For any questions regarding these Terms of Service, please contact us at admin@hemedclinic.com.',
            ],
        ];
    }
}
