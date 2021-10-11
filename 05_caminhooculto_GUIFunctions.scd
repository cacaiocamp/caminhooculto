(
{
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

				~vecLDRs[0].guiValueAvarageObj.string = ~vecLDRs[0].curValueAvarage.asString;
				~vecLDRs[1].guiValueAvarageObj.string = ~vecLDRs[1].curValueAvarage.asString;
				~vecLDRs[2].guiValueAvarageObj.string = ~vecLDRs[2].curValueAvarage.asString;
				~vecLDRs[3].guiValueAvarageObj.string = ~vecLDRs[3].curValueAvarage.asString;
				~vecLDRs[4].guiValueAvarageObj.string = ~vecLDRs[4].curValueAvarage.asString;
				~vecLDRs[5].guiValueAvarageObj.string = ~vecLDRs[5].curValueAvarage.asString;
				~vecLDRs[6].guiValueAvarageObj.string = ~vecLDRs[6].curValueAvarage.asString;
				~vecLDRs[7].guiValueAvarageObj.string = ~vecLDRs[7].curValueAvarage.asString;

				(1.0/60).wait;
			});
		}, AppClock);

		~updateGUILDRValuesTask.play();
	};

	~funcStartAvaraging = {
		~vecLDRs.size.do({
			arg index;
			~vecLDRs[index].startAvarage.value();
		});
		"---> gattering values to avarage...".postln();
	};

	~funcGenerateAvarages = {
		arg avarageType = 0;

		~vecLDRs.size.do({
			arg index;
			~vecLDRs[index].endAvarage(avarageType);
		});

		if(avarageType == 0, { //control
			"|---> control avarage values calculated".postln();
		}, {
			if(avarageType == 1, { //top
				"|---> top avarage values calculated".postln();
			}, { //avarageType == 2, bottom
				"|---> bottom avarage values calculated".postln();
			});
		});

	};

	~funcShowHideValues = {
		arg showValue = true, valueType = 0;

		if(showValue == true, {
			~vecLDRs.size.do({
				arg index;

				if(valueType == 0, { //control
					~vecLDRs[index].guiControlAvarageObj.string = ~vecLDRs[index].controlAvarage.asString;
				}, {
					if(valueType == 1, { //top
						~vecLDRs[index].guiTopAvarageObj.string = ~vecLDRs[index].topAvarage.asString;
					}, { //valueType == 2, bottom
						~vecLDRs[index].guiBottomAvarageObj.string = ~vecLDRs[index].bottomAvarage.asString;
					});
				});
			});
		}, {
			~vecLDRs.size.do({
				arg index;

				if(valueType == 0, { //control
					~vecLDRs[index].guiControlAvarageObj.string = "";
				}, {
					if(valueType == 1, { //top
						~vecLDRs[index].guiTopAvarageObj.string = "";
					}, { //valueType == 2, bottom
						~vecLDRs[index].guiBottomAvarageObj.string = "";
					});
				});
			});
		});
	};

	~funcSetLastIdentifiedLDRPattern = {
		arg ldrPatternDisplayIndexToSet, processTriggeredName;

		~lastIdentifiedLDRPatternIndex = ldrPatternDisplayIndexToSet;

		{
			~vecLastIndentifiedLDRPatternObjs[0].string_(processTriggeredName);

			for(1, 8, {
				arg i;
				~vecLastIndentifiedLDRPatternObjs[i].background_(~ldrPatternColors[~ldrPatternsDisplays[ldrPatternDisplayIndexToSet][i-1]]);
			});
		}.fork(AppClock);
	};

	~funcChangePossibleLDRPattern = {
		arg possibleLDRPatternIndex;
		var ldrPatternChoosen;

		ldrPatternChoosen = ~vecLDRPatterns.choose();

		//checks if the pattern is already selected for the current possible ones or the lastIdentified
		while({(ldrPatternChoosen.currentRelatedLDRPatternDisplayIndex != -1) || (ldrPatternChoosen.index == ~lastIdentifiedLDRPatternIndex)}, {
			ldrPatternChoosen = ~vecLDRPatterns.choose();
		});

		if(possibleLDRPatternIndex > (~vecCurrentPossibleLDRPatternIndexes.size() - 1), { //this only happens on the first time patterns are generated
			~vecCurrentPossibleLDRPatternIndexes = ~vecCurrentPossibleLDRPatternIndexes.add(ldrPatternChoosen.index);
		}, { //other times
			~vecLDRPatterns[~vecCurrentPossibleLDRPatternIndexes[possibleLDRPatternIndex]].currentRelatedLDRPatternDisplayIndex = -1;
			~vecCurrentPossibleLDRPatternIndexes[possibleLDRPatternIndex] = ldrPatternChoosen.index;
		});

		~vecLDRPatterns[ldrPatternChoosen.index].currentRelatedLDRPatternDisplayIndex = possibleLDRPatternIndex;
		~vecLDRPatterns[ldrPatternChoosen.index].processToTriggerIndex = rrand(0, ~processesArray.size - 1);
		~vecLDRPatterns[ldrPatternChoosen.index].processToTriggerName = ~processNames[~vecLDRPatterns[ldrPatternChoosen.index].processToTriggerIndex];

		{
			~vecPossibleLDRPatternsObjs[possibleLDRPatternIndex][0].string = ~vecLDRPatterns[ldrPatternChoosen.index].processToTriggerName;

			for(1, 8, {
				arg squareIndex;

				~vecPossibleLDRPatternsObjs[possibleLDRPatternIndex][squareIndex].background_(
					~ldrPatternColors[ldrPatternChoosen.displayArray[squareIndex-1]]
				);
			});
		}.fork(AppClock);
	};

	~funcStartCaminhooculto = {
		~taskUpdatePossibleLDRPatterns = Task.new({
			inf.do({
				var hasAddSynth = false;
				6.do({
					arg index;
					~funcChangePossibleLDRPattern.value(index);

					if(~vecLDRPatterns[~vecCurrentPossibleLDRPatternIndexes[index]].processToTriggerIndex == ~processesIndexes[\addSynth], {
						hasAddSynth = true;
					});
				});

				if((hasAddSynth == false) && ((~vecNodeSpawners.size == 0) || (rrand(0, 1.0) < 0.1)), {
					var indexToAddSynth = [0, 1, 2, 3, 4, 5].choose;

					~vecLDRPatterns[~vecCurrentPossibleLDRPatternIndexes[indexToAddSynth]].processToTriggerIndex = ~processesIndexes[\addSynth];
					~vecLDRPatterns[~vecCurrentPossibleLDRPatternIndexes[indexToAddSynth]].processToTriggerName = ~processNames[~processesIndexes[\addSynth]];
				});

				~possiblePatternsDuration = rrand(~minimumWaitForNewPatterns, ~maximumWaitForNewPatterns);
				~possiblePatternsDurationToDisplay = ~possiblePatternsDuration;
				~possiblePatternsDuration.wait;
			});
		}, AppClock);

		~taskUpdatePossiblePatternsDuration = Task.new({
			inf.do({
				~possiblePatternsDurationToDisplay = ~possiblePatternsDurationToDisplay - 0.1;
				if(~possiblePatternsDurationToDisplay < 0, {
					~possiblePatternsDurationToDisplay = 0;
				});
				~possibleLDRPatternsDuration_text.string = ~possiblePatternsDurationToDisplay.asStringPrec(2);
				(1.0/10).wait;
			});
		}, AppClock);

		~taskUpdatePossibleLDRPatterns.play;
		~taskUpdatePossiblePatternsDuration.play;
		~running = true;
	};
}.fork(AppClock);
)