<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (!Schema::hasColumn('users', 'government_id_hash')) {
                $table->string('government_id_hash')->nullable();
            }
            if (!Schema::hasColumn('users', 'government_id_last3')) {
                $table->string('government_id_last3', 4)->nullable();
            }
            if (!Schema::hasColumn('users', 'id_verified_at')) {
                $table->timestamp('id_verified_at')->nullable();
            }
            if (!Schema::hasColumn('users', 'role')) {
                $table->string('role')->default('commuter'); // commuter, hr_manager, mechanic
            }
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['government_id_hash', 'government_id_last3', 'id_verified_at', 'role']);
        });
    }
};
