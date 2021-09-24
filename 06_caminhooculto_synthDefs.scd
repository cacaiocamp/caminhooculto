{
	(
		SynthDef(\binauralDecoder, {
			arg inbusBF, outbus, amp=1;
			var bfsig, decode, outsig;
			bfsig = In.ar(inbusBF,4);
			decode = FoaDecode.ar(bfsig, ~decoder);
			outsig = decode*amp;
			outsig = Limiter.ar(outsig);
			Out.ar(outbus,outsig)
		}).add;

		SynthDef(\sinRhoTest, {
			arg azi, rhoBusControl, freq, freqImpulse, outbus, amp=0.3;
			var aziControl, rhoControl, sig, bfSig;

			rhoControl = In.kr(rhoBusControl, 1);
			sig = (SinOsc.ar(freq) * Impulse.kr(freqImpulse)) * amp;
			bfSig = FoaEncode.ar(sig, ~encoder);
			bfSig = FoaTransform.ar(bfSig, 'directO', ((1-1) * -1) * (pi/2));
			bfSig = FoaTransform.ar(bfSig, 'rotate', azi);

			Out.ar(outbus,bfSig)
		}).add;
	)
}.fork(SystemClock)