<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('cms_articles', function (Blueprint $table) {
            $table->foreignId('category_id')->nullable()->after('category')
                ->constrained('cms_article_categories')->nullOnDelete();
            $table->boolean('is_featured')->default(false)->after('category_id');
            $table->index('is_featured');
        });

        if (Schema::hasColumn('cms_articles', 'category')) {
            $rows = DB::table('cms_articles')
                ->whereNotNull('category')
                ->where('category', '!=', '')
                ->select(['id', 'category'])
                ->get();

            foreach ($rows as $row) {
                $category = DB::table('cms_article_categories')->where('name', $row->category)->first();
                if ($category) {
                    DB::table('cms_articles')->where('id', $row->id)->update(['category_id' => $category->id]);
                }
            }
        }
    }

    public function down(): void
    {
        Schema::table('cms_articles', function (Blueprint $table) {
            $table->dropForeign(['category_id']);
            $table->dropColumn(['category_id', 'is_featured']);
        });
    }
};
