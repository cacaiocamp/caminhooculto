(
{
	~funcInstantiateLDRs = {
		var radiansPosition = [pi/4, 0, -pi/4, pi/2, -pi/2, pi*3/4, pi, -pi*3/4];

		8.do({
			arg index;
			var newLDR;

			newLDR = ~ldrEventClassStructure.value(
				pinNumber: index,
				valueObjGUI: ~vecPinValuesStaticText[index],
				valueAvarageObjGUI: ~vecPinValuesAvaragesStaticText[index],
				controlAvarageObjGUI: ~vecPinControlAvaragesStaticText[index],
				topAvarageObjGUI: ~vecPinTopAvaragesStaticText[index],
				bottomAvarageObjGUI: ~vecPinBottomAvaragesStaticText[index],
				controlTriggerObjGUI: ~vecControlSquares[index],
				positionRadians: radiansPosition[index]
			);

			~vecLDRs = ~vecLDRs.add(newLDR);
		});

		~funcAddUpdateLDRsTask.value();
	};

	~funcAddUpdateLDRsTask = {

		~updateLDRsTask = Routine.new({
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
			});
		});

		~updateLDRsTask.play;
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
}.fork(SystemClock);
)