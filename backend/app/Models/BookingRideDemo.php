<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BookingRideDemo extends Model
{
    protected $table = 'booking_rides_demo';
    protected $guarded = [];
    protected $casts = [
        'waypoints' => 'array',
        'polyline' => 'array',
    ];
}
