<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class GoogleAuthController extends Controller
{
    public function handleGoogleCallback(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'name' => 'required|string',
            'google_id' => 'required|string',
            'avatar' => 'nullable|string',
        ]);

        // Find or create user
        $user = User::where('email', $request->email)->first();

        if ($user) {
            // Update existing user with Google info
            $user->update([
                'google_id' => $request->google_id,
                'avatar' => $request->avatar,
            ]);
        } else {
            // Create new user
            $user = User::create([
                'name' => $request->name,
                'email' => $request->email,
                'google_id' => $request->google_id,
                'avatar' => $request->avatar,
                'password' => Hash::make(Str::random(32)), // Random password for OAuth users
            ]);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'user' => $user,
            'access_token' => $token,
            'token_type' => 'Bearer',
        ]);
    }
}
