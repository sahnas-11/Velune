<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class EmergencyIncident extends Model
{
    protected $table = 'emergency_incidents';
    protected $guarded = [];

    public function events()
    {
        return $this->hasMany(EmergencyIncidentEvent::class, 'incident_id');
    }

    public function messages()
    {
        return $this->hasMany(EmergencyIncidentMessage::class, 'incident_id');
    }

    public function technicianNotes()
    {
        return $this->hasMany(EmergencyTechnicianNote::class, 'incident_id');
    }

    public function diagnosticCodes()
    {
        return $this->hasMany(EmergencyDiagnosticCode::class, 'incident_id');
    }

    public function notifications()
    {
        return $this->hasMany(EmergencyNotification::class, 'incident_id');
    }
}
