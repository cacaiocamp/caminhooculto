~processNames = ["changePatterns", "shortAttacks", "addSynth", "killSynth", "panDirect", "panAvarage", "wavetbInterpol", "changeEnv", "iterations", "killAll"];

( //processes list
~processesArray = [
	~changePatternsProcess = { //0
		~shortAttacksOn = false;

		{
			~taskUpdatePossibleLDRPatterns.stop;
			~taskUpdatePossiblePatternsDuration.stop;

			~funcStartCaminhooculto.value();
		}.fork;
	},

	~shortAttacksProcess = {//1
		~shortAttacksOn = true;
	},

	~addSynthProcess = { //2 - code retrieved and modified from Eli Fieldsteel's wavetable synthesis tutorial
		var wavetableSignals, wavetableBuffers, synthToAdd;

		//6 wavetables with increasing spectrum complexity
		wavetableSignals = 6.collect({
			arg i;

			//random number of envelope segments
			var numSegs = i.linexp(0,9,4,40).round;

			Env(
				//env always begins and ends with zero
				//inner points are random from -1.0 to 1.0
				[0] ++ ({1.0.rand}.dup(numSegs-1) * [1,-1]).scramble ++ [0],

				//greater segment duration variety in higher-index wavetables
				{exprand(1,i.linexp(0,9,1,50))}.dup(numSegs),

				//low-index wavetables tend to be sinusoidal
				//high index wavetables tend to have sharp angles and corners
			{[\sine,0,exprand(1,20) * [1,-1].choose].wchoose([9-i,3,i].normalizeSum)}.dup(numSegs)
			).asSignal(1024);
		});

		//load into 10 buffers in wavetable format
		wavetableBuffers = Buffer.allocConsecutive(6, s, 2048, 1, {
			arg buf, index;
			buf.setnMsg(0, wavetableSignals[index].asWavetable);
		});

		synthToAdd = ~nodeSpawnerEventClassStructure.value();

		synthToAdd.setNodeSpawner(wavetableBuffers);

		~vecNodeSpawners = ~vecNodeSpawners.add(synthToAdd);
	},

	~killSynthProcess = { //3

	},

	~panDirectProcess = { //4

	},

	~panAvarageProcess = { //5

	},

	~wavetbInterpolProcess = { //6

	},

	~changeEnvProcess = { //7

	},

	~iterationsProcess = { //8

	},

	~killAllProcess = {//9
		~shortAttacksOn = false;

	};
];
)