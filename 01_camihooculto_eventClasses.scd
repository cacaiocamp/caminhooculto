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
					if(((self.curValueAvarage < self.controlAvarage) && (self.controlValueTriggered == 1)) ||
					   ((self.curValueAvarage > self.controlAvarage) && (self.controlValueTriggered == -1)),{
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
					self.controlAvarage = (sum/arraySize).round.asInteger + 10;
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
									self.newSynth = Synth(\osc, [
										\azi, self.positionAzi,
										\rhoBusControl, self.valueBus,
										\outbus, ~busA_BF_toDecode
									], ~group_nodes);
								});
							},{
								self.newSynth.free;
							});

							taskToReturn.stop;
						});

						if(((self.curValueAvarage > self.controlAvarage) && (self.controlValueTriggered == 1)) ||
							((self.curValueAvarage < self.controlAvarage) && (self.controlValueTriggered == -1)),{
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

	~nodeSpawnerEventClassStructure = {
		(
			busesRelatedArray: nil,
			buffersRelatedArray: nil,
			outbus: nil,

			taskNodeSpawner: nil,
			nodeSpawnerGroup: nil,
			nodeSpawnerControlerABus: nil,

			curNodes: nil,
			controlNode: nil,

			controlNodeKillEnvDur: nil,

			aziPos: nil,
			aziRange: nil,
			envelopeType: ~envTypes[\crescendo],
			directBufPos: 1,
			curBufPosGate: 1,

			getNewEnvelope: {
				arg self;
				var envelope, choosenEnvelope, envSize, minEnvDur, maxEnvDur;

				if(self.envelopeType == ~envTypes[\anyType], {
					var envelopeChance;
					envelopeChance = rrand(0, 4);

					choosenEnvelope = envelopeChance;
				}, {
					choosenEnvelope = self.envelopeType;
				});

				envSize = rrand(3, 25);
				minEnvDur = rrand(3, 5.0);
				maxEnvDur = minEnvDur + rrand(0.0, 10.0);

				if(choosenEnvelope == ~envTypes[\random], { //random env
					envelope = Env.new(
						[0] ++ ({1.0.rand}.dup(envSize-2)).scramble ++ [0],
						({rrand(minEnvDur/envSize, maxEnvDur/envSize)}.dup(envSize)).scramble
					);
				}, {
					if(choosenEnvelope == ~envTypes[\sine], { //sine env
						var envSteps = 1.0/(envSize-2), curValue = 0, durSteps = maxEnvDur/envSize, env;

						env = ((envSize-2)/2).asInteger.collect({curValue = curValue + envSteps; curValue}) ++ ((envSize-2)/2).asInteger.collect({curValue = curValue - envSteps; curValue});

						envelope = Env.new(
							[0] ++ env ++ [0],
							envSize.collect({durSteps})
						);
					}, {
						if(choosenEnvelope == ~envTypes[\twoPeaks], { //two peaks env
							envelope = Env.new(
								[0, 1, 0, 0, 1, 0],
								[rrand(0.2, 1.0), rrand(0.2, 1.0), rrand(0.2, 1.0), rrand(0.2, 1.0), rrand(0.2, 1.0)]
							);
						}, {
							if(choosenEnvelope == ~envTypes[\shortPeaks],{ //short peaks env
								var numPeaks = rrand(2, 11), env, count = 0;

								env = ((numPeaks-1)*3).collect({
									var numToReturn;

									if(count == 0, {
										numToReturn = 1;
									}, {
										numToReturn = 0;
									});

									count = count + 1;

									if(count == 3, {
										count = 0;
									});

									numToReturn
								}) ++ [1];

								envelope = Env.new(
									[0] ++ env ++ [0],
									(numPeaks + (numPeaks * 3)).collect(rrand(0.02, 0.7/numPeaks));
								);
							}, { //choosenEnvelope == ~envTypes[\crescendo] --- crescendo env
								envelope = Env.new(
									[0, 1, 0],
									[rrand(minEnvDur/2, maxEnvDur/3), rrand(0.05, 0.1)]
								);
							});
						});
					});
				});

				envelope
			},

			setNodeSpawner: {
				arg self,
				    buffersRelated = [],
				    triggeredLDRsIndexList,
				    notTriggeredLDRsIndexList,
				    outbus = ~busA_BF_toDecode;
				var valuesAvarage = [], aziPos = rrand(0, 2.0), aziRange = 0.25;

				self.buffersRelatedArray = buffersRelated;
				self.outbus = outbus;
				self.aziPos = aziPos;
				self.envelopeType = ~currentEnvelopeType;

				if(notTriggeredLDRsIndexList.size > 0, {
					notTriggeredLDRsIndexList.do({
						arg index;

						valuesAvarage = valuesAvarage.add(~vecLDRs[index].curValueAvarage.linlin(~vecLDRs[index].controlAvarage, ~vecLDRs[index].topAvarage, 0, 1));
					});

					valuesAvarage = valuesAvarage.sum / valuesAvarage.size;
				}, {
					valuesAvarage = 0;
				});


				self.taskNodeSpawner = Task.new({
					var closeEnvChance, killNodeSpawnerEnv;

					self.nodeSpawnerGroup = Group.new(~group_nodes, \addToHead);
					self.nodeSpawnerControlerABus = Bus.audio(s, 1);

					closeEnvChance = rrand(0.0, 1.0);

					if(closeEnvChance >= 0.5, {
						var durToDie = rrand(0.5, 3);
						killNodeSpawnerEnv = Env.new(
							[0, 1, 0], [0.1, durToDie], releaseNode: 1
						);
					}, {
						var durToRise = rrand(1, 3), durToDie = rrand(0.1, 0.5), ampToRise = rrand(1.2, 1.5);
						killNodeSpawnerEnv = Env.new(
							[0, 1, ampToRise, 0], [0.1, durToRise, durToDie], releaseNode: 1
						);
					});

					self.controlNodeKillEnvDur = killNodeSpawnerEnv.duration;

					self.controlNode = Synth(\nodeSpawnerControl, [
						\signalBus, self.nodeSpawnerControlerABus,
						\directAzi, aziPos,
						\directRho, 0,
						\env, killNodeSpawnerEnv,
						\outbus,  ~busA_BF_toDecode
					], self.nodeSpawnerGroup, \addToTail);

					inf.do({
						var envelope, freqStart, freqEnd, detune, waitBetweenNodes = rrand(0.0, 1.5 * (~vecNodeSpawners.size + 1));

						envelope = self.getNewEnvelope();

						freqStart = (valuesAvarage * 25.midicps) + 16.midicps;
						freqEnd = freqStart + (rrand(0, 1.5).midicps);

						self.curNodes = rrand(~minNodesPerNodeSpawner, ~maxNodesPerNodeSpawner).collect({
							Synth(\wavetableSynthesis, [
								\bufnumStart, self.buffersRelatedArray[0],
								\bufnumEnd, self.buffersRelatedArray[self.buffersRelatedArray.size() - 1],
								\bufPosGate, self.curBufPosGate,
								\freqStart, freqStart.midicps,
								\freqEnd, freqEnd.midicps,
								\detune, rrand(0.05, 0.2),
								\amp, 0.1 + rrand(0, 0.2),
								\env, envelope,
								\outbus, self.nodeSpawnerControlerABus
							], self.nodeSpawnerGroup, \addToHead);
						});

						self.curNodes.do({
							arg node;

							NodeWatcher.register(node);
						});

						(envelope.totalDuration).wait;
						waitBetweenNodes.wait;
					});
				}, SystemClock);

				self.taskNodeSpawner.play;
			},

			setEnvelopeType: {
				arg self, triggeredLDRsList, notTriggeredLDRsList;
				var aziMovDur, aziMovTask, aziMovPosArray = [], valuesAvarage;

				if(notTriggeredLDRsList.size > 0, {
					notTriggeredLDRsList.do({
						arg index;

						valuesAvarage = valuesAvarage.add(~vecLDRs[index].curValueAvarage.linlin(~vecLDRs[index].controlAvarage, ~vecLDRs[index].topAvarage, 0, 1));
					});

					valuesAvarage = valuesAvarage.sum / valuesAvarage.size;
				}, {
					valuesAvarage = 0;
				});

				if(valuesAvarage < 0.2, {
					self.envelopeType = ~envTypes[\shortPeaks];
				}, {
					if(valuesAvarage < 0.4, {
						self.envelopeType = ~envTypes[\crescendo];
					}, {
						if(valuesAvarage < 0.6, {
							self.envelopeType = ~envTypes[\twoPeaks];
						}, {
							if(valuesAvarage < 0.8, {
								self.envelopeType = ~envTypes[\sine];
							}, {
								self.envelopeType = ~envTypes[\anyEnv];
							});
						});
					});
				});

				self.envelopeType
			},

			changeDirectAzi: {
				arg self, triggeredLDRsList, notTriggeredLDRsList;
				var aziMovDur, aziMovTask, aziMovPosArray = [], valuesAvarage;

				if(notTriggeredLDRsList.size > 0, {
					notTriggeredLDRsList.do({
						arg index;

						valuesAvarage = valuesAvarage.add(~vecLDRs[index].curValueAvarage.linlin(~vecLDRs[index].controlAvarage, ~vecLDRs[index].topAvarage, 0, 1));
					});

					valuesAvarage = valuesAvarage.sum / valuesAvarage.size;
				}, {
					valuesAvarage = 0;
				});


				if(valuesAvarage < 0.25, { //full circle movement, random direction
					var mov = [-2, 2].choose;
					aziMovPosArray = aziMovPosArray.add(self.aziPos + mov);
					aziMovDur = rrand(1.0, 5.0);
				}, {
					if(valuesAvarage < 0.5, { //half circle movement, random direction
						var mov = [-1, 1].choose;
						aziMovPosArray = aziMovPosArray.add(self.aziPos + mov);
						aziMovDur = rrand(0.5, 5.0);
					}, {
						if(valuesAvarage < 0.75, { //other fractions movement, random direction
							var mov = [2/rrand(1.25, 7), -2/rrand(1.25, 7)].choose;
							aziMovPosArray = aziMovPosArray.add(self.aziPos + mov);
							aziMovDur = rrand(0.5, 2.0);
						}, { // 2 directions mov
							var mov = [2/rrand(1.25, 7), -2/rrand(1.25, 7)].choose;
							aziMovPosArray = aziMovPosArray.add(self.aziPos + mov);
							mov = [2/rrand(1.25, 7), -2/rrand(1.25, 7)].choose;
							aziMovPosArray = aziMovPosArray.add(self.aziPos + mov);
							aziMovDur = rrand(2.0, 5.0);
						});
					});
				});

				aziMovTask = Task.new({
					var aziSteps;

					if(aziMovPosArray.size > 1, {
						var count = 0, firstDirectionDur, secondDirectionDur;

						firstDirectionDur = aziMovDur/rrand(2.0, 4.0);
						secondDirectionDur = aziMovDur - firstDirectionDur;

						aziSteps = (self.aziPos - aziMovPosArray[0]) / (firstDirectionDur * 1000);

						{
							(firstDirectionDur * 1000).do({
								self.aziPos = self.aziPos - aziSteps;
								self.controlNode.set(\directAzi, self.aziPos);

								(1.0/1000).wait;
							});

							aziSteps = (self.aziPos - aziMovPosArray[1]) / (secondDirectionDur * 1000);

							(secondDirectionDur * 1000).do({
								self.aziPos = self.aziPos - aziSteps;
								self.controlNode.set(\directAzi, self.aziPos);

								(1.0/1000).wait;
							});

							aziMovTask.stop;
						}.fork();
					}, {
						var count = 0;
						aziSteps = (self.aziPos - aziMovPosArray[0]) / (aziMovDur * 1000);

						inf.do({
							self.aziPos = self.aziPos - aziSteps;
							self.controlNode.set(\directAzi, self.aziPos);

							(1.0/1000).wait;

							count = count + 1;

							if(count >= (aziMovDur * 1000), {
								aziMovTask.stop;
							});
						});
					});
				}, SystemClock);

				aziMovTask.play;
			},

			selectWavetables: {
				arg self, triggeredLDRsList, notTriggeredLDRsList;
				var changeWavetablesTask, valuesAvarage, newBufGateValue;

				if(notTriggeredLDRsList.size > 0, {
					notTriggeredLDRsList.do({
						arg index;

						valuesAvarage = valuesAvarage.add(~vecLDRs[index].curValueAvarage.linlin(~vecLDRs[index].controlAvarage, ~vecLDRs[index].topAvarage, 0, 1));
					});

					valuesAvarage = valuesAvarage.sum / valuesAvarage.size;
				}, {
					valuesAvarage = 0;
				});

				if(valuesAvarage <= 0.75, {
					newBufGateValue = 0;
				}, {
					if(valuesAvarage > 0.75, {
						newBufGateValue = 1;
					});
				});

				changeWavetablesTask = Task.new({
					var numSteps = rrand(300, 3000), bufPosGateStep, newBufPosGate;

					newBufPosGate = self.curBufPosGate;

					bufPosGateStep = (newBufGateValue - self.curBufPosGate) / numSteps;

					{

						self.curNodes.size.do({
							arg index;
							if(self.curNodes[index].isPlaying, {
								self.curNodes[index].set(\directBufPosition, valuesAvarage);
							});
						});

						self.directBufPos = valuesAvarage;

						numSteps.do({
							newBufPosGate = newBufPosGate + bufPosGateStep;

							self.curNodes.size.do({
								arg index;

								if(self.curNodes[index].isPlaying, {
									self.curNodes[index].set(\bufPosGate, newBufPosGate);
								});
							});

							self.curBufPosGate = newBufPosGate;

							(1.0/1000).wait;
						});

						changeWavetablesTask.stop;
					}.fork();
				}, SystemClock);

				changeWavetablesTask.play;
			},

			killNodeSpawner: {
				arg self;
				var closeEnvTask;

				closeEnvTask = Task.new({
					self.controlNode.set(\gate, 0.0);

					{
						self.taskNodeSpawner.stop;
						self.nodeSpawnerControlerABus.free;
						closeEnvTask.stop;
					}.defer(self.controlNodeKillEnvDur);

				}, SystemClock);

				closeEnvTask.play;
			},

			instantKillNodeSpawner: {
				arg self;
				var instantKillTask;

				instantKillTask = Task.new({
					var ampSteps = 0.01, newAmp = 1;

					100.do({
						newAmp = newAmp - ampSteps;

						self.controlNode.set(\amp, newAmp);

						(1.0/1000).wait;
					});

					{
						self.taskNodeSpawner.stop;
						self.nodeSpawnerGroup.free;
						self.nodeSpawnerControlerABus.free;
						instantKillTask.stop;
					}.defer(0.1);
				}, SystemClock);

				instantKillTask.play;
			}
		)
	};

}.fork(SystemClock);
)