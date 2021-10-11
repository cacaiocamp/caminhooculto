{
	(
		//ambisonics binauralDecoder
		SynthDef(\binauralDecoder, {
			arg inbusBF, outbus, amp=1;
			var bfSignal, decode, outsig;

			bfSignal = In.ar(inbusBF,4);
			decode = FoaDecode.ar(bfSignal, ~decoder);
			outsig = decode * amp;
			outsig = Limiter.ar(outsig);

			Out.ar(outbus, outsig)
		}).add;

		//short attacks synthDef
		SynthDef(\sinRhoTest, {
			arg azi, rhoBusControl, freq, freqImpulse, outbus, amp=0.3;
			var aziControl, rhoControl, signal, bfSignal;

			rhoControl = In.kr(rhoBusControl, 1);
			signal = (SinOsc.ar(freq) * Impulse.kr(freqImpulse)) * amp;
			bfSignal = FoaEncode.ar(signal, ~encoder);
			bfSignal = FoaTransform.ar(bfSignal, 'directO', (rhoControl) * (pi/2));
			bfSignal = FoaTransform.ar(bfSignal, 'rotate', azi);

			Out.ar(outbus, bfSignal)
		}).add;

		//main nodeSpawner synthDef
		SynthDef(\wavetableSynthesis, {
			arg bufnumStart, bufnumEnd, bufPosGate = 1, directBufPosition = 0, directBufPostionRange = 0.2, freqStart, freqEnd, amp = 0.2, detune = 0.2, outbus;
			var signal, detuneControl, bufPosition, bufPositionDirect, bufPositionRandom, freqVariation, envelope, envControl;

			//bufPosGate controls if  using directBufPosition or LFNoise1 range. When bufPosGate is 1, bufPositionRandom is used; when 0 direcBufPosition is used;
			bufPositionDirect = ((bufPosGate - 1) * -1 * (directBufPosition + LFNoise1.kr(0.5).range(-0.1, 0.1)).linlin(-0.1, 0.9, bufnumStart, bufnumEnd));
			bufPositionRandom = bufPosGate * (LFNoise1.kr(0.5).range(bufnumStart, bufnumEnd));
			bufPosition =  bufPositionDirect + bufPositionRandom;

			freqVariation = LFNoise1.kr(0.5).range(freqStart, freqEnd);
			detuneControl = LFNoise1.kr(0.1).bipolar(detune).midiratio;

			envControl = Control.names([\env]).kr(Env.newClear(50).asArray);
			envelope = EnvGen.kr(envControl, doneAction: 2);

			signal = VOsc.ar(bufPosition, freqVariation * detuneControl, {Rand(0,2pi)});

			Out.ar(outbus, signal * envelope * amp);
		}).add;

		//nodeSpawner group control
		SynthDef(\nodeSpawnerControl, {
			arg signalBus, directAzi = 0, aziRange = 0.25, directRho = 0, rhoRange = 1.0/6, gate = 1.0, amp = 1, outbus = ~busA_BF_toDecode;
			var signalIn, bfSignal, bfSignalOut, azi, rho, envControl, envelope;

			signalIn = In.ar(signalBus, 1);
			rho = LFNoise1.kr(0.5).range(0, rhoRange);
			azi = LFNoise1.kr(0.5).range(-1 * (aziRange/2), aziRange/2);

			envControl = Control.names([\env]).kr(Env.newClear(10).asArray);
			envelope = EnvGen.kr(envControl, gate, doneAction: 14);

			signalIn = signalIn * envelope;
			signalIn = LeakDC.ar(signalIn);

			bfSignal = FoaEncode.ar(signalIn, ~encoder);
			bfSignalOut = FoaTransform.ar(bfSignal, 'directO', (directRho + rho) * pi/2);
			bfSignalOut = FoaTransform.ar(bfSignal, 'rotate', (directAzi + azi) * pi); // azi goes from 0-front to pi-back

			Out.ar(outbus, bfSignalOut);
		}).add;
	)
}.fork(SystemClock)