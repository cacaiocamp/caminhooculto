(
{
	~funcInstantiateLDRPatterns = {
		~ldrPatternsDisplays.do({
			arg ldrPatternDisplay, ldrPatternDisplayIndex;
			var newLDRpattern;

			newLDRpattern = ~ldrPatternEventClassStructure.value(
				patternIndex: ldrPatternDisplayIndex,
				patternDisplayArray: ldrPatternDisplay
			);

			~vecLDRPatterns = ~vecLDRPatterns.add(newLDRpattern);
		});
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
			if(~lastIdetifiedLDRPatternIndex != patternFoundIndex, {
				~funcSetLastIdentifiedLDRPattern.value(patternFoundIndex, ~vecLDRPatterns[patternFoundIndex].processToTriggerName);
				~lastIdetifiedLDRPatternIndex = patternFoundIndex;
			});

			~processesArray[~vecLDRPatterns[patternFoundIndex].processToTriggerIndex].value();
		});
	};
}.fork(SystemClock);
)