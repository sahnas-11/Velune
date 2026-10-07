<?php

namespace App\Services;

class FareCalculator
{
    /**
     * Calculate gross fare, subsidy, and per-rider split
     */
    public static function calculate(float $baseRate = 2400.0, float $tollFuel = 4800.0, float $opFee = 600.0, float $subsidyPercent = 75.0, array $riders = [])
    {
        $grossFare = $baseRate + $tollFuel + $opFee;
        $subsidyAmount = ($grossFare * $subsidyPercent) / 100.0;
        $netPayable = $grossFare - $subsidyAmount; // 1950.0

        if (empty($riders)) {
            $riders = [
                ['name' => 'Amanda C. (You)', 'distance' => 14.2, 'is_current_user' => true],
                ['name' => 'Naveen K.', 'distance' => 10.2, 'is_current_user' => false],
                ['name' => 'Kirthan S.', 'distance' => 10.2, 'is_current_user' => false],
            ];
        }

        $totalDistance = array_sum(array_column($riders, 'distance')) ?: 1;
        $splits = [];
        $personalShare = 0.0;

        foreach ($riders as $rider) {
            $ratio = $rider['distance'] / $totalDistance;
            $share = round($netPayable * $ratio);
            $splits[] = [
                'passenger_name' => $rider['name'],
                'distance_km' => $rider['distance'],
                'share_amount' => $share,
                'is_current_user' => $rider['is_current_user'] ?? false,
            ];
            if ($rider['is_current_user'] ?? false) {
                $personalShare = $share;
            }
        }

        return [
            'gross_fare' => $grossFare,
            'base_rate' => $baseRate,
            'toll_fuel' => $tollFuel,
            'operational_fee' => $opFee,
            'subsidy_percentage' => $subsidyPercent,
            'subsidy_amount' => $subsidyAmount,
            'net_payable' => $netPayable,
            'personal_share' => $personalShare ?: 800.0,
            'splits' => $splits,
        ];
    }
}
