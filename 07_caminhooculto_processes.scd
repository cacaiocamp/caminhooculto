~processNames = ["changePatterns", /*"shortAttacks",*/ "addSynth", "killSynth", "panDirect", /*"panAvarage",*/ "wavetbInterpol", "changeEnv", "changeAllEnvs", "killAll"/*, "startStopAll"*/];

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

	/*~shortAttacksProcess = {//1
		~shortAttacksOn = true;
	},*/

	~addSynthProcess = { //2 - code modified from Eli Fieldsteel's wavetable synthesis tutorial
		arg triggeredLDRs;
		var wavetableSignals, wavetableBuffers, triggeredLDRsIndexList = [], notTriggeredLDRsIndexList = [], synthToAdd;

		~shortAttacksOn = false;

		//10 wavetables with increasing spectrum complexity
		wavetableSignals = 10.collect({
			arg i;

			//random number of envelope segments
			var numSegs = i.linexp(0,9,2,40).round;

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
		wavetableBuffers = Buffer.allocConsecutive(10, s, 2048, 1, {
			arg buf, index;
			buf.setnMsg(0, wavetableSignals[index].asWavetable);
		});

		triggeredLDRs.do({
			arg isLdrTriggered, index;

			if(isLdrTriggered == 1, {
				triggeredLDRsIndexList = triggeredLDRsIndexList.add(index);
			}, {
				notTriggeredLDRsIndexList = notTriggeredLDRsIndexList.add(index);
			});
		});

		synthToAdd = ~nodeSpawnerEventClassStructure.value();

		synthToAdd.setNodeSpawner(wavetableBuffers, triggeredLDRsIndexList, notTriggeredLDRsIndexList);

		~vecNodeSpawners = ~vecNodeSpawners.add(synthToAdd);
	},

	~killSynthProcess = { //3
		var randomNodeSpawnerIndex;

		~shortAttacksOn = false;

		randomNodeSpawnerIndex = rrand(0, ~vecNodeSpawners.size - 1);

		~vecNodeSpawners[randomNodeSpawnerIndex].killNodeSpawner();

		~vecNodeSpawners[randomNodeSpawnerIndex] = nil;
		~vecNodeSpawners.removeAt(randomNodeSpawnerIndex);
	},

	~panDirectProcess = { //4
		arg triggeredLDRs;
		var numNodeSpawnersToPan, randomNodeSpawnerIndex, triggeredLDRsIndexList = [], notTriggeredLDRsIndexList = [];

		~shortAttacksOn = false;

		numNodeSpawnersToPan = rrand(1, ~vecNodeSpawners.size);

		triggeredLDRs.do({
			arg isLdrTriggered, index;

			if(isLdrTriggered == 1, {
				triggeredLDRsIndexList = triggeredLDRsIndexList.add(index);
			}, {
				notTriggeredLDRsIndexList = notTriggeredLDRsIndexList.add(index);
			});
		});

		numNodeSpawnersToPan.do({
			randomNodeSpawnerIndex = rrand(0, ~vecNodeSpawners.size - 1);
			~vecNodeSpawners[randomNodeSpawnerIndex].changeDirectAzi(triggeredLDRsIndexList, notTriggeredLDRsIndexList);
		});
	},

	/*~panAvarageProcess = { //5

	},*/

	~wavetbInterpolProcess = { //6
		arg triggeredLDRs;
		var numNodeSpawnersToChangeSpectrum, randomNodeSpawnerIndex, triggeredLDRsIndexList = [], notTriggeredLDRsIndexList = [];

		~shortAttacksOn = false;

		numNodeSpawnersToChangeSpectrum = rrand(1, ~vecNodeSpawners.size);

		triggeredLDRs.do({
			arg isLdrTriggered, index;

				if(isLdrTriggered == 1, {
				triggeredLDRsIndexList = triggeredLDRsIndexList.add(index);
			}, {
				notTriggeredLDRsIndexList = notTriggeredLDRsIndexList.add(index);
			});
		});

		numNodeSpawnersToChangeSpectrum.do({
			randomNodeSpawnerIndex = rrand(0, ~vecNodeSpawners.size - 1);
			~currentEnvelopeType = ~vecNodeSpawners[randomNodeSpawnerIndex].selectWavetables(triggeredLDRsIndexList, notTriggeredLDRsIndexList);
		});
	},

	~changeEnvProcess = { //7
		arg triggeredLDRs;
		var numNodeSpawnersToChangeEnv, randomNodeSpawnerIndex, triggeredLDRsIndexList = [], notTriggeredLDRsIndexList = [];

		~shortAttacksOn = false;

		numNodeSpawnersToChangeEnv = rrand(1, ~vecNodeSpawners.size);

		triggeredLDRs.do({
			arg isLdrTriggered, index;

			if(isLdrTriggered == 1, {
				triggeredLDRsIndexList = triggeredLDRsIndexList.add(index);
			}, {
				notTriggeredLDRsIndexList = notTriggeredLDRsIndexList.add(index);
			});
		});

		numNodeSpawnersToChangeEnv.do({
			randomNodeSpawnerIndex = rrand(0, ~vecNodeSpawners.size - 1);
			~vecNodeSpawners[randomNodeSpawnerIndex].setEnvelopeType(triggeredLDRsIndexList, notTriggeredLDRsIndexList);
		});
	},

	~changeAllEnvsProcess = { //8
		arg triggeredLDRs;
		var nodeSpawnerIndex, triggeredLDRsIndexList = [], notTriggeredLDRsIndexList = [];

		~shortAttacksOn = false;

		triggeredLDRs.do({
			arg isLdrTriggered, index;

			if(isLdrTriggered == 1, {
				triggeredLDRsIndexList = triggeredLDRsIndexList.add(index);
			}, {
				notTriggeredLDRsIndexList = notTriggeredLDRsIndexList.add(index);
			});
		});

		~vecNodeSpawners.size.do({
			arg nodeSpawnerIndex;
			~currentEnvelopeType = ~vecNodeSpawners[nodeSpawnerIndex].setEnvelopeType(triggeredLDRsIndexList, notTriggeredLDRsIndexList);
		});
	},

	~killAllProcess = {//9
		~shortAttacksOn = false;

		~vecNodeSpawners.size.do({
			~vecNodeSpawners[0].instantKillNodeSpawner();
			~vecNodeSpawners.removeAt(0);
		});
	}

	/*~startStopAllProcess = { //10
		~shortAttacksOn = false;

		~vecNodeSpawners.size.do({
			//se abaixo de x, triga todos nodeSpawners, se não, amp 0 no control
		});
	};*/
];
)