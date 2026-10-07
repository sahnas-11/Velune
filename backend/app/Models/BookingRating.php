<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class BookingRating extends Model
{
    protected $table = 'booking_ratings';
    protected $guarded = [];
    protected $casts = [
        'feedback_tags' => 'array',
    ];
}
