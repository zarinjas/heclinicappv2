<?php

namespace App\Traits;

use Illuminate\Database\Eloquent\Builder;

trait BranchScoped
{
    protected function scopeToUserBranch(Builder $query): Builder
    {
        $user = auth()->user();

        if ($user && ($user->isBranchAdmin() || $user->isStaff()) && $user->branch_id) {
            $query->where('branch_id', $user->branch_id);
        }

        return $query;
    }

    protected function scopeCalendarToUserBranch(Builder $query): Builder
    {
        $user = auth()->user();

        if ($user && ($user->isBranchAdmin() || $user->isStaff()) && $user->branch_id) {
            $query->whereHas('doctor', function ($q) use ($user) {
                $q->where('branch_id', $user->branch_id);
            });
        }

        return $query;
    }
}
