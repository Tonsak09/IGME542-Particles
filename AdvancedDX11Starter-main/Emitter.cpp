#pragma once
#include "Emitter.h"

#include "WICTextureLoader.h"

#include "Helpers.h"

Emitter::Emitter(float pLifetime, int emitRate, wstring texturePath, 
	Microsoft::WRL::ComPtr<ID3D11Device> device,
	Microsoft::WRL::ComPtr<ID3D11DeviceContext> context) :
	pLifetime(pLifetime), emitRate(emitRate)
{
	// Load particle texture 
	CreateWICTextureFromFile(device.Get(), context.Get(), FixPath(texturePath).c_str(), 0, particleTexture.GetAddressOf());
}
Emitter::~Emitter()
{
	delete[] particles;
}

/// <summary>
/// Tracks lifetimes and emits particles 
/// </summary>
void Emitter::Update(float delta)
{
	currentTime += delta;
	timeSinceLastEmit += delta;

	// Iterate through each particle and check lifetime
	// Does need to emit 

	// Note: We want to get rid of all particles
	//		 that should be dead this update instead
	//		 of letting them grow and only killing one 
	//		 at a time each update 

	int currIndex = liveStart;
	for (int i = 0; i < liveCount; i++)
	{
		if (currentTime - particles[currIndex].emitTime < pLifetime)
		{
			// New beginning found 
			break;
		}

		// Particle has gone passed lifetime 
		currIndex++; 
		if (currIndex >= ringBufferSize)
		{
			currIndex = 0;
		}

		liveStart = currIndex;
	}

	if (timeSinceLastEmit > timeBetweenParticles)
	{
		// In case multiple need to be spawned 
		int count = timeSinceLastEmit / timeBetweenParticles;

		// Dis to max from next end 
		int nextEndToBufferMax = ringBufferSize - (liveEnd + count);

		if (nextEndToBufferMax < 0)
		{
			// Split into two chunks 
			
			int currToMaxDis = ringBufferSize - liveEnd;
			for (int i = 0; i < currToMaxDis; i++)
			{
				particles[liveEnd + i + 1].emitTime = currentTime;
				// Set start pos 
			}

			// Looped
			// Note: currEndToBufferMax represents overflow 
			// Todo: Does not account for multiple overflow 
			int overFlow = abs(nextEndToBufferMax);
			for (int i = 0; i < overFlow; i++)
			{
				particles[i].emitTime = currentTime;
			}

		}	
		else
		{
			// Does not loop buffer 
			for (int i = 0; i < count; i++)
			{
				particles[liveEnd + i + 1].emitTime = currentTime;
				// Set start pos 
			}
		}
	}
}

/// <summary>
/// Sends CPU date to GPU 
/// </summary>
void Emitter::Draw()
{
	// Does this need to be split into two? 
	if (liveEnd < liveStart)
	{
		// Send into two batches
		SendToGPU(liveStart, ringBufferSize - 1);
		SendToGPU(0, liveEnd);
	}
	else
	{
		// Send in one batch 
		SendToGPU(liveStart, liveEnd);
	}
}

void Emitter::SendToGPU(int start, int end)
{

}