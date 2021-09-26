{
	(
		SynthDef(\binauralDecoder, {
			arg inbusBF, outbus, amp=1;
			var bfSignal, decode, outsig;

			bfSignal = In.ar(inbusBF,4);
			decode = FoaDecode.ar(bfSignal, ~decoder);
			outsig = decode * amp;
			outsig = Limiter.ar(outsig);

			Out.ar(outbus, outsig)
		}).add;

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

		SynthDef(\wavetableSynthesis, {
			arg bufnumStart, bufnumEnd, freqStart, freqEnd, amp = 0.2, rhoDistance = pi/6, detune = 0.2, outbus;
			var signal, detuneControl, bfSignal, bufPosition, freqVariation, envelope, envControl, aziEnvelope, aziEnvControl, rho;

			bufPosition = LFNoise1.kr(0.5).range(bufnumStart, bufnumEnd);

			freqVariation = LFNoise1.kr(0.5).range(freqStart, freqEnd);
			detuneControl = LFNoise1.kr(0.1).bipolar(detune).midiratio;

			envControl = Control.names([\env]).kr(Env.newClear(50).asArray);
			envelope = EnvGen.kr(envControl, doneAction: 2);

			aziEnvControl = Control.names([\aziEnv]).kr(Env.newClear(50).asArray);
			aziEnvelope = EnvGen.kr(aziEnvControl, doneAction: 0);

			rho = LFNoise1.kr(0.5).range(0, rhoDistance);

			signal = VOsc.ar(bufPosition, freqVariation * detuneControl, {Rand(0,2pi)});
			signal = LeakDC.ar(signal);
			bfSignal = FoaEncode.ar(signal * envelope * amp, ~encoder);
			bfSignal = FoaTransform.ar(bfSignal, 'directO', rho);
			bfSignal = FoaTransform.ar(bfSignal, 'rotate', aziEnvelope * pi); // azi goes from 0-front to pi-back

			Out.ar(outbus, bfSignal);
		}).add;
	)
}.fork(SystemClock)