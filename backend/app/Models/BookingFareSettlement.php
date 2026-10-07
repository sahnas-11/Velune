<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BookingFareSettlement extends Model
{
    protected $table = 'booking_fare_settlements';
    protected $guarded = [];

    public function splits()
    {
        return $this->hasMany(BookingFareSplit::class, 'settlement_id');
    }
}
