<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BookingTrip extends Model
{
    protected $table = 'booking_trips';
    protected $guarded = [];

    public function events()
    {
        return $this->hasMany(BookingTripEvent::class, 'trip_id');
    }

    public function settlement()
    {
        return $this->hasOne(BookingFareSettlement::class, 'trip_id');
    }

    public function receipt()
    {
        return $this->hasOne(BookingReceipt::class, 'trip_id');
    }
}
