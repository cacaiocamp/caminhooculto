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
~record = false;
~running = false;

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
	[3, 0, 0, 3, 3, 0, 0, 3], //a0, a3, a4, a7
	[3, 0, 0, 3, 0, 2, 2, 0], //a1, a2, a5, a6
	[0, 2, 2, 0, 3, 0, 0, 3], //a1, a2, a4, a7
	[1, 1, 1, 1, 1, 1, 1, 1]
];

// --- Other DEFAULT values
~controlValueTrigInterval = 1500; //in msec
~ldrValueAvarageSize = 24;

// --- Initialisations
~vecLDRs = [];
~vecLDRPatterns = [];
~vecControlSquares = [];
~vecCurrentPossibleLDRPatternIndexes = [];
~lastIdetifiedLDRPatternIndex = -1;
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

			"--> searching for device at por".postln();
			SerialPort.devices.do({
				arg device;
				if(device.asString == ~portName.asString, {
					~portFound = true;
				});
			});
			s.sync;

			if(~portFound == true, {
				//serialPort
				~arduinoSerialPort = SerialPort.new(~portName, 9600, crtscts: true);
				s.sync;

				// define encoder / decoder matrices
				~encoder = FoaEncoderMatrix.newDirection;
				~decoder = FoaDecoderKernel.newCIPIC; // kernel decoders should be freed after use!!
				s.sync;

				//buses de controle e buffers
				s.sync;

				//outras variaveis globais
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
				/*
				~group_soundIn = Group.new(~group_master, \addToHead);
				~group_liveRoute = Group.new(~group_master, \addToTail);
				~group_sustainProcs = Group.new(~group_master, \addToTail);
				~group_grainProcs = Group.new(~group_master, \addToTail);
				~group_reverb = Group.new(~group_master, \addToTail);
				*/
				s.sync;

				~busA_speakersOut = Bus.new('audio',~speakerBuses[0], 2);
				~busA_BF_toDecode = Bus.audio(s, 4);
				/*
				~busA_saxIn = Bus.audio(s, 1);

				~busA_BF_liveRoute = Bus.audio(s, 4);
				~busA_BF_sustainProcs = Bus.audio(s, 4);
				~busA_BF_grainProcs = Bus.audio(s, 4);
				~busA_BF_reverb =  Bus.audio(s, 4);
				buses de audio
				*/
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