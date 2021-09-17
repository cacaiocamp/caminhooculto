(
{
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

		~lastIdetifiedLDRPatternIndex = ldrPatternDisplayIndexToSet;

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

		while({ldrPatternChoosen.currentRelatedLDRPatternDisplayIndex != -1}, {
			ldrPatternChoosen = ~vecLDRPatterns.choose();
		});

		if(possibleLDRPatternIndex > (~vecCurrentPossibleLDRPatternIndexes.size() - 1), {
			~vecCurrentPossibleLDRPatternIndexes = ~vecCurrentPossibleLDRPatternIndexes.add(ldrPatternChoosen.index);
		}, {
			~vecLDRPatterns[~vecCurrentPossibleLDRPatternIndexes[possibleLDRPatternIndex]].currentRelatedLDRPatternDisplayIndex = -1;
			~vecCurrentPossibleLDRPatternIndexes[possibleLDRPatternIndex] = ldrPatternChoosen.index;
		});

		~vecLDRPatterns[ldrPatternChoosen.index].currentRelatedLDRPatternDisplayIndex = possibleLDRPatternIndex;
		~vecLDRPatterns[ldrPatternChoosen.index].processToTriggerName = "abcdefghijklmnopq".scramble;
		//add process index

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
				6.do({
					arg index;
					~funcChangePossibleLDRPattern.value(index);
				});

				~possiblePatternsDuration = ((40.0.rand) + 10.0);
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
	};
}.fork(AppClock);
)