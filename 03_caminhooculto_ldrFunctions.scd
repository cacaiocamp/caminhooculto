(
{
	~funcInstantiateLDRs = {
		8.do({
			arg index;
			var newLDR;

			newLDR = ~ldrEventClassStructure.value(
				pinNumber: index,
				valueObjGUI: ~vecPinValuesStaticText[index],
				controlAvarageObjGUI: ~vecPinControlAvaragesStaticText[index],
				topAvarageObjGUI: ~vecPinTopAvaragesStaticText[index],
				bottomAvarageObjGUI: ~vecPinBottomAvaragesStaticText[index],
				controlTriggerObjGUI: ~vecControlSquares[index]
			);

			~vecLDRs = ~vecLDRs.add(newLDR);
		});

		~funcAddUpdateLDRsTask.value();
	};

	~funcAddUpdateLDRsTask = {

		~updateLDRsTask = Task.new({
			inf.do({
				var byteReceived, fullMessage, ldrMessage;
				if(~arduinoSerialPort.read==10, {
					fullMessage = "";
					ldrMessage = "";

					while({byteReceived = ~arduinoSerialPort.read; byteReceived !=13 }, {
						fullMessage = fullMessage ++ byteReceived.asAscii;
						ldrMessage = ldrMessage ++ byteReceived.asAscii;

						//byte 59 = ';', separator of each ldr value that come from arduino
						if(byteReceived == 59, {
							~funcGetValuesFromLDRMessage.value(ldrMessage);
							ldrMessage="";
						});
					});

					~funcGetValuesFromLDRMessage.value(ldrMessage++';');

					if(~postValues == true, {
						(~portName+"read message:"+fullMessage).postln;
					});
				});
				(1.0/9600).wait;
			});
		}, SystemClock);

		~updateLDRsTask.start;
	};

	// LDR Message structure
	// char 0 = 'A', char 1 = pinNumber, char 2 = '=', char 3-4-5-6 = pinValue, char.last = ';'
	~funcGetValuesFromLDRMessage = {
		arg ldrMessage;
		var analogPinNumber = ldrMessage[1], valueMessage = "";

		for(3, ldrMessage.size - 2, {
			arg valueIndex;
			valueMessage = valueMessage ++ ldrMessage[valueIndex];
		});

		~vecLDRs[analogPinNumber.asString.asInteger].updateCurValue(valueMessage.asInteger);
	};

	~funcStartLDRGuiUpdateTasks = {
		~updateGUILDRValuesTask = Task.new({
			inf.do({
				~vecLDRs[0].guiValueObj.string = ~vecLDRs[0].curValue.asString;
				~vecLDRs[1].guiValueObj.string = ~vecLDRs[1].curValue.asString;
				~vecLDRs[2].guiValueObj.string = ~vecLDRs[2].curValue.asString;
				~vecLDRs[3].guiValueObj.string = ~vecLDRs[3].curValue.asString;
				~vecLDRs[4].guiValueObj.string = ~vecLDRs[4].curValue.asString;
				~vecLDRs[5].guiValueObj.string = ~vecLDRs[5].curValue.asString;
				~vecLDRs[6].guiValueObj.string = ~vecLDRs[6].curValue.asString;
				~vecLDRs[7].guiValueObj.string = ~vecLDRs[7].curValue.asString;

				(1.0/60).wait;
			});
		}, AppClock);

		~updateGUILDRValuesTask.play();
	};

	~funcCheckPatternToTrigger = {
		var triggeredLDRs = [], patternFoundIndex = -1;

		for(0, 7, {
			arg i;

			if(~vecLDRs[i].controlValueTriggered == -1, {
				triggeredLDRs = triggeredLDRs.add(1);
			}, {
				triggeredLDRs = triggeredLDRs.add(0);
			});
		});

		~vecCurrentPossibleLDRPatternIndexes.do({
			arg ldrPatternIndex;
			var differenceFound = false;

			~ldrPatternsDisplays[ldrPatternIndex].do({
				arg triggerValue, valueIndex;
				var trigOnOff = 0;

				if(triggerValue >= 1, {
					trigOnOff = 1;
				});

				if(trigOnOff != triggeredLDRs[valueIndex], {
					differenceFound = true;
				});
			});

			if(differenceFound == false, {
				patternFoundIndex = ldrPatternIndex;
			});
		});

		if(patternFoundIndex != -1, {
			//check if process is different
			if(~lastIdetifiedLDRPatternIndex != patternFoundIndex, {
				~funcSetLastIdentifiedLDRPattern.value(patternFoundIndex, ~vecLDRPatterns[patternFoundIndex].processToTriggerName);
				~lastIdetifiedLDRPatternIndex = patternFoundIndex;
			});
			//trigger process
		});
	};
}.fork(SystemClock);
)