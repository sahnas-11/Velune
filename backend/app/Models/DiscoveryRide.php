<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DiscoveryRide extends Model
{
    protected $table = 'discovery_rides';
    protected $guarded = [];
    protected $casts = [
        'polyline' => 'array',
        'verified_only' => 'boolean',
    ];
}
