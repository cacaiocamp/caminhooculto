// --- Classes as Events

(
{
	// --- LDR Class
	~ldrEventClassStructure = {
		arg pinNumber, valueObjGUI, valueAvarageObjGUI, controlAvarageObjGUI, topAvarageObjGUI, bottomAvarageObjGUI, controlTriggerObjGUI, positionRadians;
		var pinNum = pinNumber,
		    guiObj = valueObjGUI,
		    guiAvarageObj = valueAvarageObjGUI,
	    	guiControlObj = controlAvarageObjGUI,
	    	guiTopValueObj = topAvarageObjGUI,
	    	guiBottomObj = bottomAvarageObjGUI,
		    guiControlTriggerObj = controlTriggerObjGUI
	    ;
		(
			pin: pinNum,
			guiValueObj: guiObj,
			guiValueAvarageObj: guiAvarageObj,
			guiControlAvarageObj: guiControlObj,
			guiTopAvarageObj: guiTopValueObj,
			guiBottomAvarageObj: guiBottomObj,
			controlValueTriggerObj: guiControlTriggerObj,

			curValue: 0,
			curValueAvarage: 0,
			curValueAvarageArray: [],
			valueBus: Bus.control(s, 1),
			valueAvarageBus: Bus.control(s, 1),
			positionAzi: positionRadians,
			newSynth: nil,

			calculatingAvarage: false,
			valuesToAvarage: [],

			controlAvarage: nil,
			topAvarage: nil,
			bottomAvarage: nil,

			controlValueTriggered: 1, //--- -1_triggered, 0_on task, 1_not triggered

			updateCurValue: {
				arg self, newValue;

				self.curValue = newValue;

				if(self.curValueAvarageArray.size <= ~ldrValueAvarageSize, {
					self.curValueAvarageArray = self.curValueAvarageArray.add(self.curValue);
				}, {
					self.curValueAvarageArray.removeAt(0);
					self.curValueAvarageArray = self.curValueAvarageArray.add(self.curValue);
				});
				self.curValueAvarage = (self.curValueAvarageArray.sum / self.curValueAvarageArray.size).asInteger;

				if((self.topAvarage != nil) && (self.bottomAvarage != nil), {
					self.valueBus.set(self.curValue.linlin(self.bottomAvarage, self.topAvarage, 0, 1));
					self.valueAvarageBus.set(self.curValueAvarage.linlin(self.bottomAvarage, self.topAvarage, 0, 1));
				}, {
					self.valueBus.set(self.curValue);
					self.valueAvarageBus.set(self.curValueAvarage);
				});


				if(self.calculatingAvarage == true, {
					self.valuesToAvarage = self.valuesToAvarage.add(self.curValue);
				});

				if(self.controlAvarage != nil, {
					if(((self.curValue < self.controlAvarage) && (self.controlValueTriggered == 1)) ||
					   ((self.curValue > self.controlAvarage) && (self.controlValueTriggered == -1)),{
						self.trigControlSquare(1);
						self.taskControlValueTrigger.start;
					});
				});
			},
			startAvarage: {
				arg self;

				self.valuesToAvarage = [];
				self.calculatingAvarage = true;
			},
			endAvarage: {
				arg self, avarageType = 0; //0-control, 1-top, 2-bottom
				var sum = 0,
				    arraySize = self.valuesToAvarage.size;

				for(0, arraySize - 1, {
					arg index;
					sum = sum + self.valuesToAvarage[index];
				});

				if(avarageType == 0, { //control
					self.controlAvarage = (sum/arraySize).round.asInteger;
				}, {
					if(avarageType == 1, { //top
						self.topAvarage = (sum/arraySize).round.asInteger;
					}, { //bottom
						self.bottomAvarage = (sum/arraySize).round.asInteger;
					});
				});

				self.calculatingAvarage = false;
			},
			trigControlSquare: {
				arg self, colorIndex;
				{
					self.controlValueTriggerObj.background_(~controlSquareColors[colorIndex]);
				}.fork(AppClock);
			},
			taskControlValueTrigger: {
				arg self;
				var taskToReturn;

				taskToReturn = Task.new({
					var milisecCount = 0;

					inf.do({
						if(milisecCount == ~controlValueTrigInterval, {
							self.controlValueTriggered = self.controlValueTriggered * -1;
							self.trigControlSquare(self.controlValueTriggered+1);

							~funcCheckPatternToTrigger.value();

							if(self.controlValueTriggered == -1, {
								if((~running == true) && (~shortAttacksOn == true),{
									self.newSynth = Synth(\sinRhoTest, [
										\azi, self.positionAzi,
										\rhoBusControl, self.valueBus,
										\freq, rrand(100, 2000),
										\freqImpulse, rrand(6, 16),
										\outbus, ~busA_BF_toDecode
									], ~group_nodes);
								});
							},{
								self.newSynth.free;
							});

							taskToReturn.stop;
						});

						if(((self.curValue > self.controlAvarage) && (self.controlValueTriggered == 1)) ||
							((self.curValue < self.controlAvarage) && (self.controlValueTriggered == -1)),{
							self.trigControlSquare(self.controlValueTriggered+1);
							taskToReturn.stop;
						});

						milisecCount = milisecCount + 1;
						(1.0/1000).wait;
					});
				});

				taskToReturn
			}
		)
	};

	~ldrPatternEventClassStructure = {
		arg patternIndex, patternDisplayArray;
		(
			index: patternIndex,
			displayArray: patternDisplayArray,
			currentRelatedLDRPatternDisplayIndex: -1,
			processToTriggerName: "none",
			processToTriggerIndex: -1
		)
	};

}.fork(SystemClock);
)