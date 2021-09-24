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

	~addSynthProcess = { //2

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