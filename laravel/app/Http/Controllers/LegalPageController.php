<?php

namespace App\Http\Controllers;

use App\Models\CmsLegalPage;
use Illuminate\Contracts\View\View;

/**
 * Renders the public, admin-editable legal pages (Privacy Policy and Terms of
 * Service) at /privacy-policy and /terms-of-service. The content lives in the
 * `cms_legal_pages` table and is managed from Admin → CMS → Legal Pages.
 */
class LegalPageController extends Controller
{
    public function show(string $slug): View
    {
        $page = CmsLegalPage::query()
            ->where('slug', $slug)
            ->where('is_active', true)
            ->first();

        abort_if($page === null, 404);

        return view('legal', ['page' => $page]);
    }
}
