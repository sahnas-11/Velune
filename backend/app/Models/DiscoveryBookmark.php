<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DiscoveryBookmark extends Model
{
    protected $table = 'discovery_bookmarks';
    protected $guarded = [];

    public function ride()
    {
        return $this->belongsTo(DiscoveryRide::class, 'ride_id');
    }
}
