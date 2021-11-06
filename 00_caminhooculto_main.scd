// --- SERIAL connection
~portName = "COM5";
~portFound = false;
~postValues = false;

// --- Ambisonics config
~outSetup = \binaural;
~speakerDistance = 1;
~speakerBuses = [0,1];

// --- In/Out devices config
//~outDevice, "CABLE Input";
~outDevice = nil;
//~inOutDevice, "AudioBox ASIO Driver";

// --- Other configs
~record = true;
~running = false;

// --- Dictionaries
~envTypes = Dictionary.newFrom(List[\anyType, -1, \random, 0, \sine, 1, \twoPeaks, 2, \shortPeaks, 3, \crescendo, 4]);
~processesIndexes = Dictionary.newFrom(List[\changePatterns, 0, \addSynth, 1, \killSynth, 2, \panDirect, 3, \wavetbInterpol, 4, \changeEnv, 5, \changeAllEnvs, 6, \killAll, 7]);

// --- DEFAULT GUI values
~avaibleBounds = Window.screenBounds;  //- Rect containing the maximum width and height for the Views
~defaultGUIMargin = 3;
~ldrPatternColors = [
	Color.new(0,0,0,0),
	Color.new(0.3, 0.5, 0.3, 0.7),
	Color.new(0.5, 0.3, 0.3, 0.7),
	Color.new(0.3, 0.3, 0.5, 0.7)
];
~controlSquareColors = [
	Color.new(153.0/255, 51.0/255, 153.0/255, 0.3),
	Color.new(0.6, 0.6, 0.6, 0.1),
	Color.new(0,0,0,0)
];

// --- DEFAULT LDR Pattern Displays
~ldrPatternsDisplays = [ //indexes of ~ldrPatternColors, also showing witch ldr values should be less then the control value to trigger
	[1, 0, 0, 0, 0, 0, 0, 1], //a0, a7
	[0, 0, 1, 0, 0, 1, 0, 0], //a2, a5
	[0, 1, 0, 0, 0, 0, 1, 0], //a1, a6
	[0, 0, 0, 1, 1, 0, 0, 0], //a3, a4
	[0, 1, 0, 0, 0, 1, 0, 1], //a1, a5, a7
	[1, 0, 1, 0, 0, 0, 1, 0], //a0, a2, a6
	[1, 0, 0, 0, 1, 1, 0, 0], //a0, a4, a5
	[0, 0, 1, 1, 0, 0, 0, 1], //a2, a3, a7
	[0, 1, 0, 1, 1, 0, 1, 0], //a1, a3, a4, a6
	[1, 0, 1, 0, 0, 1, 0, 1], //a0, a2, a5, a7
	[0, 2, 2, 0, 0, 2, 2, 0], //a1, a2, a5, a6
	[2, 2, 0, 0, 0, 0, 2, 2], //a0, a1, a6, a7
	[3, 0, 0, 3, 3, 0, 0, 3], //a0, a3, a4, a7
	[0, 0, 3, 3, 3, 3, 0, 0], //a2, a3, a4, a5
	[3, 0, 0, 3, 0, 2, 2, 0], //a1, a2, a5, a6
	[0, 2, 2, 0, 3, 0, 0, 3], //a1, a2, a4, a7
	[3, 2, 2, 3, 0, 0, 0, 0], //a0, a1, a2, a3
	[0, 0, 0, 0, 3, 2, 2, 3], //a4, a5, a6, a7
	[0, 1, 1, 1, 1, 0, 1, 0], //a1, a2, a3, a4, a6
	[0, 1, 0, 1, 1, 1, 1, 0], //a1, a3, a4, a5, a6
	[0, 1, 0, 1, 1, 0, 1, 1], //a1, a3, a4, a6, a7
	[1, 1, 0, 1, 1, 0, 1, 0], //a0, a1, a3, a4, a6
	[3, 1, 3, 3, 3, 0, 0, 0], //a0, a1, a2, a3, a4
	[2, 2, 0, 1, 0, 2, 2, 0], //a0, a1, a3, a5, a6
	[0, 0, 0, 3, 3, 3, 1, 3], //a3, a4, a5, a6, a7
	[0, 2, 2, 0, 1, 0, 2, 2], //a1, a2, a4, a6, a7
	[0, 1, 1, 1, 1, 1, 1, 0], //a1, a2, a3, a4, a5, a6
	[1, 1, 0, 1, 1, 0, 1, 1], //a0, a1, a3, a4, a6, a7
	[1, 1, 1, 1, 1, 1, 1, 1]
];

// --- Other DEFAULT values
~controlValueTrigInterval = 750; //in msec
~ldrValueAvarageSize = 24; //how many ldrValues to group for avaraging
~minNodesPerNodeSpawner = 2;
~maxNodesPerNodeSpawner = 4;
~minimumWaitForNewPatterns = 15.0;
~maximumWaitForNewPatterns = 45.0;

// --- Initialisations
~vecLDRs = [];
~vecLDRPatterns = [];
~vecNodeSpawners = [];
~vecControlSquares = [];
~vecCurrentPossibleLDRPatternIndexes = [];
~lastIdentifiedLDRPatternIndex = -1;
~vecLastIndentifiedLDRPatternObjs = [];
~vecPossibleLDRPatternsObjs = [];
~vecPinValuesStaticText = [];
~vecPinValuesAvaragesStaticText = [];
~vecPinControlAvaragesStaticText = [];
~vecPinTopAvaragesStaticText = [];
~vecPinBottomAvaragesStaticText = [];
~updateLDRsTask = nil;
~updateGUILDRValuesTask = nil;
~possiblePatternsDuration = 0; //in sec
~possiblePatternsDurationToDisplay = 0; //in sec
~shortAttacksOn = false;
~currentEnvelopeType = ~envTypes[\crescendo];

// --- Server config
s = Server.local;
o = s.options;
o.outDevice = ~outDevice;
s.options.blockSize = 128;
s.options.sampleRate = 48000;

(
s.boot;

~mainroutine = Routine({

	s.waitForBoot({
		{
			s.newAllocators;
			s.sync;

			("--> searching for device at port" + ~portName).postln();
			SerialPort.devices.do({
				arg device;
				if(device.asString == ~portName.asString, {
					~portFound = true;
					"|--> device found".postln();
				});
			});
			s.sync;

			if(~portFound == true, {
				if(~record == true, {
					{
						s.recHeaderFormat = "wav";
						s.sync;
						s.record;
						(0.02).wait;
					}.fork();
				});

				//serialPort
				~arduinoSerialPort = SerialPort.new(~portName, 9600, crtscts: true);
				s.sync;

				// define encoder / decoder matrices
				~encoder = FoaEncoderMatrix.newDirection;
				~decoder = FoaDecoderKernel.newCIPIC; // kernel decoders should be freed after use!!
				s.sync;

				//documentos
				this.executeFile(Document.current.dir +/+ "01_camihooculto_eventClasses.scd");
				this.executeFile(Document.current.dir +/+ "02_caminhooculto_GUI.scd");
				this.executeFile(Document.current.dir +/+ "03_caminhooculto_ldrFunctions.scd");
				this.executeFile(Document.current.dir +/+ "04_caminhooculto_ldrPatternFunctions.scd");
				this.executeFile(Document.current.dir +/+ "05_caminhooculto_GUIFunctions.scd");
				this.executeFile(Document.current.dir +/+ "06_caminhooculto_synthDefs.scd");
				this.executeFile(Document.current.dir +/+ "07_caminhooculto_processes.scd");
				s.sync;

				//instantiate sensor objects
				~funcInstantiateLDRs.value();
				s.sync;
				~funcStartLDRGuiUpdateTasks.value();
				s.sync;

				//instantiate ldrPattern objects
				~funcInstantiateLDRPatterns.value();
				s.sync;

				//groups
				~group_master = Group.new();
				~group_nodes = Group.new(~group_master, \addToHead);
				~group_decoders = Group.new(~group_master, \addToTail); //needs to be the last group
				s.sync;

				~busA_speakersOut = Bus.new('audio',~speakerBuses[0], 2);
				~busA_BF_toDecode = Bus.audio(s, 4);
				s.sync;

				"\n|--------> caminhooculto started <--------|".postln;

				//ambisonics node initialization
				(~outSetup == \binaural).if({
					~speakerDecoder = Synth(\binauralDecoder,
						[
							\inbusBF, ~busA_BF_toDecode,
							\outbus, ~busA_speakersOut,
							\amp, 1
						], ~group_decoders
					);
					"|--> decoder binaural/out added".postln;
				});
			}, {
				("\n|--------> caminhooculto FAILED : SerialPort " ++ ~portName.asString ++ " not found <--------|").postln;
			});
		}.fork(AppClock);
	});
}).play(AppClock);

)