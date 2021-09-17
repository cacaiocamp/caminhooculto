(
AppClock.sched(0,{
	var margin = ~defaultGUIMargin,
	    windowWidthProp = 0.72,
	    windowHeightProp = 0.75,

	    vecLDRDrawPositions = [],
	    //----- Pen definitions
	        centerSquareWidth = 0,
		    centerSquareHeight = 0,
		    centerSquarePosX = 0,
		    centerSquarePosY = 0,
	        ldrsDiameter = 0,
		    shellMarginWidth = 0,
		    shellMarginHeight = 0,
	    //----- Pin control squares
	        a0ControlSquare_view,
	        a1ControlSquare_view,
	        a2ControlSquare_view,
	        a3ControlSquare_view,
	        a4ControlSquare_view,
	        a5ControlSquare_view,
	        a6ControlSquare_view,
	        a7ControlSquare_view,
	    //----- Pin identifications
	        a0Header_staticText,
	        a1Header_staticText,
	        a2Header_staticText,
	        a3Header_staticText,
	        a4Header_staticText,
	        a5Header_staticText,
	        a6Header_staticText,
	        a7Header_staticText,
	    //----- Pin values
	        a0Value_staticText,
	        a1Value_staticText,
	        a2Value_staticText,
	        a3Value_staticText,
	        a4Value_staticText,
	        a5Value_staticText,
	        a6Value_staticText,
	        a7Value_staticText,
	    //----- Control Pin values
	        a0ControlValue_staticText,
	        a1ControlValue_staticText,
	        a2ControlValue_staticText,
	        a3ControlValue_staticText,
	        a4ControlValue_staticText,
	        a5ControlValue_staticText,
	        a6ControlValue_staticText,
	        a7ControlValue_staticText,
	    //----- Top Pin values
	        a0TopValue_staticText,
	        a1TopValue_staticText,
	        a2TopValue_staticText,
	        a3TopValue_staticText,
	        a4TopValue_staticText,
	        a5TopValue_staticText,
	        a6TopValue_staticText,
	        a7TopValue_staticText,
	    //----- Bottom Pin values
	        a0BottomValue_staticText,
	        a1BottomValue_staticText,
	        a2BottomValue_staticText,
	        a3BottomValue_staticText,
	        a4BottomValue_staticText,
	        a5BottomValue_staticText,
	        a6BottomValue_staticText,
	        a7BottomValue_staticText,
	    //----- Buttons
	        buttonIndexingPoint,

	        avarageControlValues_button,
	        avarageControlValues_buttonHeader,
	        showAvarageControlValues_button,
	        showAvarageControlValues_buttonHeader,

	        setValuesTop_button,
	        setValuesTop_buttonHeader,
	        showValuesTop_button,
	        showValuesTop_buttonHeader,

	        setValuesBottom_button,
	        setValuesBottom_buttonHeader,
	        showValuesBottom_button,
	        showValuesBottom_buttonHeader,

	        postValues_button,
	        postValues_buttonHeader,

	        start_button,
	        start_buttonHeader,
	    //----- Last Indentified LDRPattern
		    lastIndentifiedLDRPatternPosX = 0,
		    lastIndentifiedLDRPatternPosY = 0,
		    lastIndentifiedLDRPatternLength = 0,
		    lastIndentifiedLDRPatternSquaresHorizontalIndex = 0,
		    lastIndentifiedLDRPatternSquaresVerticalIndex = 0,

	        lastIdentifiedLDRPattern_header,
	        lastIdentifiedLDRPatternProcessTriggered_header,
	        lastIdentifiedLDRPatternProcessTriggered_text,
	        lastIdentifiedLDRPattern_A0View,
	        lastIdentifiedLDRPattern_A1View,
	        lastIdentifiedLDRPattern_A2View,
	        lastIdentifiedLDRPattern_A3View,
	        lastIdentifiedLDRPattern_A4View,
	        lastIdentifiedLDRPattern_A5View,
	        lastIdentifiedLDRPattern_A6View,
	        lastIdentifiedLDRPattern_A7View,
	    //----- Possible LDRPatterns
	        possibleLDRPatternsPosX = 0,
	        possibleLDRPatternsPosY = 0,
		    possibleLDRPatternsLength = 0,
		    possibleLDRPatternsHorizontalDistance = 0,
		    possibleLDRPatternsVerticalDistance = 0,
		    possibleLDRPatternsHorizontalIndex = 0,
		    possibleLDRPatternssVerticalIndex = 0,

	        possibleLDRPatterns_header
	        //~possibleLDRPatternsDuration_text
	;

	//--------------- guiCaminhoOculto config
	~guiCaminhoOcultoWinWidth = ~avaibleBounds.width * windowWidthProp;
	~guiCaminhoOcultoWinHeight = ~avaibleBounds.height * windowHeightProp;
	~guiCaminhoOcultoWin = Window.new(
		"caminhooculto_GUI",
		Rect((~avaibleBounds.width - ~guiCaminhoOcultoWinWidth)/2, (~avaibleBounds.height - ~guiCaminhoOcultoWinHeight)/2, ~guiCaminhoOcultoWinWidth, ~guiCaminhoOcultoWinHeight),
		false
	).background_(Color.hsv(0.65,0.1,0.3,0.3)).front;
	~guiCaminhoOcultoWin.alpha = 0.9;
	~guiCaminhoOcultoWin.onClose = {

		"-->> stopping caminhooculto...".postln;

		"--> closing serial port connection".postln;
		~arduinoSerialPort.close;
		"|--> serial port connection closed".postln;

		~updateLDRsTask.stop;
		~updateGUILDRValuesTask.stop;
		~taskUpdatePossibleLDRPatterns.stop;
		~taskUpdatePossiblePatternsDuration.stop;

		/*~vecJoycons.do({
			arg joycon;
			joycon.searchCommandsTask.stop;
			joycon.searchCommandsTask.free;

			joycon.vecOscFuncs.do({
				arg oscFunc;
				oscFunc.free;
			});

			joycon.vecSynths.do({
				arg synth;
				synth.free;
			});

			~joyconInputsWithBuses.do({
				arg inputWithBusName;
				var inputBusSymbol = (inputWithBusName ++ "_bus").asSymbol;

				joycon[inputBusSymbol].free;
			});

		});*/

		"--> freeing decoder...".postln;
		~decoder.free;
		~speakerDecoder.free;
		"|--> decoder and decoderSynth freed".postln;
		"\n|--------> caminhooculto stopped <--------|".postln;
	};

	~compsBgWidth = ~guiCaminhoOcultoWinWidth - (2*margin);
	~compsBgHeight = ~guiCaminhoOcultoWinHeight - (2*margin);
	~compsBg = CompositeView(~guiCaminhoOcultoWin,Rect(margin,margin,~compsBgWidth, ~compsBgHeight)).background_(Color.hsv(0.66,0.8,0.4,0.3));

	~textSizeGeneral = ~guiCaminhoOcultoWinHeight/58;

	//--------------- errorWin
	~errorWinWidth = ~guiCaminhoOcultoWinWidth;
	~errorWinHeigth = ~guiCaminhoOcultoWinHeight/2;

	//--------------- pendrawings indexing
	shellMarginWidth = ~guiCaminhoOcultoWinWidth/27;
	shellMarginHeight = ~guiCaminhoOcultoWinHeight/7.5;

	centerSquareWidth = 2*~guiCaminhoOcultoWinWidth/5;
	centerSquareHeight = ~guiCaminhoOcultoWinHeight - (3*shellMarginHeight);
	centerSquarePosX = (~guiCaminhoOcultoWinWidth/2) - (centerSquareWidth/2);
	centerSquarePosY = shellMarginHeight*3/2;
	ldrsDiameter = shellMarginWidth/2;

	lastIndentifiedLDRPatternPosX = margin + (shellMarginWidth * 5/2);
	lastIndentifiedLDRPatternPosY = (~guiCaminhoOcultoWinHeight/2)-(shellMarginHeight/4);
	lastIndentifiedLDRPatternLength = (centerSquarePosX-(shellMarginWidth*1.5)) - lastIndentifiedLDRPatternPosX;

	possibleLDRPatternsLength = lastIndentifiedLDRPatternLength * 1.2/2;
	possibleLDRPatternsPosX = centerSquarePosX + centerSquareWidth + (shellMarginWidth * 5/8);
	possibleLDRPatternsPosY = centerSquarePosY + (((centerSquareHeight/3) - (possibleLDRPatternsLength))/2);
	possibleLDRPatternsHorizontalDistance = (shellMarginWidth * 5/8);
	possibleLDRPatternsVerticalDistance = ((centerSquareHeight/3) - (possibleLDRPatternsLength))/2;

	vecLDRDrawPositions = vecLDRDrawPositions.add(Point.new(centerSquarePosX + ((centerSquareWidth/3)/2) - (ldrsDiameter/2), centerSquarePosY + ((centerSquareHeight/3)/2) - (ldrsDiameter/2)));
	vecLDRDrawPositions = vecLDRDrawPositions.add(Point.new(centerSquarePosX + ((centerSquareWidth/3)/2) +  (centerSquareWidth/3) - (ldrsDiameter/2), centerSquarePosY + ((centerSquareHeight/3)/2) - (ldrsDiameter/2)));
	vecLDRDrawPositions = vecLDRDrawPositions.add(Point.new(centerSquarePosX + ((centerSquareWidth/3)/2) +  (2*(centerSquareWidth/3)) - (ldrsDiameter/2), centerSquarePosY + ((centerSquareHeight/3)/2) - (ldrsDiameter/2)));
	vecLDRDrawPositions = vecLDRDrawPositions.add(Point.new(centerSquarePosX + ((centerSquareWidth/3)/2) - (ldrsDiameter/2), centerSquarePosY + ((centerSquareHeight/3)/2) + (centerSquareHeight/3) - (ldrsDiameter/2)));
	vecLDRDrawPositions = vecLDRDrawPositions.add(Point.new(centerSquarePosX + ((centerSquareWidth/3)/2) +  (2*(centerSquareWidth/3)) - (ldrsDiameter/2), centerSquarePosY + ((centerSquareHeight/3)/2) + (centerSquareHeight/3) - (ldrsDiameter/2)));
	vecLDRDrawPositions = vecLDRDrawPositions.add(Point.new(centerSquarePosX + ((centerSquareWidth/3)/2) - (ldrsDiameter/2), centerSquarePosY + ((centerSquareHeight/3)/2) + (2*(centerSquareHeight/3)) - (ldrsDiameter/2)));
	vecLDRDrawPositions = vecLDRDrawPositions.add(Point.new(centerSquarePosX + ((centerSquareWidth/3)/2) +  (centerSquareWidth/3) - (ldrsDiameter/2), centerSquarePosY + ((centerSquareHeight/3)/2) + (2*(centerSquareHeight/3)) - (ldrsDiameter/2)));
	vecLDRDrawPositions = vecLDRDrawPositions.add(Point.new(centerSquarePosX + ((centerSquareWidth/3)/2) +  (2*(centerSquareWidth/3)) - (ldrsDiameter/2), centerSquarePosY + ((centerSquareHeight/3)/2) + (2*(centerSquareHeight/3)) - (ldrsDiameter/2)));

	//--------------- Pen drawings
	~guiCaminhoOcultoWin.drawFunc = {
		var curCelcenterSquarePosX = 0,
		    curCelcenterSquarePosY = 0
		;

		//-- ferrero rocher shell
		Pen.strokeColor = Color.new(1, 1, 1, 0.6);
		Pen.moveTo((3*shellMarginWidth)@shellMarginHeight);
		Pen.curveTo(shellMarginWidth@(shellMarginHeight*3/2), (3*shellMarginWidth)@shellMarginHeight, shellMarginWidth@shellMarginHeight);
		Pen.lineTo(shellMarginWidth@(~guiCaminhoOcultoWinHeight-(shellMarginHeight*3/2)));
		Pen.curveTo(
			(3*shellMarginWidth)@(~guiCaminhoOcultoWinHeight-shellMarginHeight),
			shellMarginWidth@(~guiCaminhoOcultoWinHeight-shellMarginHeight),
			(3*shellMarginWidth)@(~guiCaminhoOcultoWinHeight-shellMarginHeight)
		);
		Pen.lineTo((~guiCaminhoOcultoWinWidth-(3*shellMarginWidth))@(~guiCaminhoOcultoWinHeight-shellMarginHeight));
		Pen.curveTo(
			(~guiCaminhoOcultoWinWidth-shellMarginWidth)@(~guiCaminhoOcultoWinHeight-(shellMarginHeight*3/2)),
			(~guiCaminhoOcultoWinWidth-(3*shellMarginWidth))@(~guiCaminhoOcultoWinHeight-shellMarginHeight),
			(~guiCaminhoOcultoWinWidth-shellMarginWidth)@(~guiCaminhoOcultoWinHeight-shellMarginHeight)
		);
		Pen.lineTo((~guiCaminhoOcultoWinWidth-shellMarginWidth)@(shellMarginHeight*3/2));
		Pen.curveTo(
			(~guiCaminhoOcultoWinWidth-(3*shellMarginWidth))@shellMarginHeight,
			(~guiCaminhoOcultoWinWidth-shellMarginWidth)@(shellMarginHeight*3/2),
			(~guiCaminhoOcultoWinWidth-shellMarginWidth)@shellMarginHeight
		);
		Pen.lineTo((3*shellMarginWidth)@shellMarginHeight);
		Pen.stroke;

		//-- caminho oculto squares
		Pen.strokeColor =  Color.new(153/255, 102/255, 0, 0.9);
		Pen.moveTo(centerSquarePosX@centerSquarePosY);
		Pen.lineTo(centerSquarePosX + centerSquareWidth@centerSquarePosY);
		Pen.lineTo(centerSquarePosX + centerSquareWidth@(centerSquarePosY + centerSquareHeight));
		Pen.lineTo(centerSquarePosX@(centerSquarePosY + centerSquareHeight));
		Pen.lineTo(centerSquarePosX@centerSquarePosY);
		Pen.stroke;

		Pen.strokeColor =  Color.new(153/255, 102/255, 0, 0.3);
		Pen.moveTo((centerSquarePosX + (centerSquareWidth/3))@centerSquarePosY);
		Pen.lineTo((centerSquarePosX + (centerSquareWidth/3))@(centerSquarePosY + centerSquareHeight));
		Pen.stroke;

		Pen.strokeColor =  Color.new(153/255, 102/255, 0, 0.3);
		Pen.moveTo((centerSquarePosX + (2*centerSquareWidth/3))@centerSquarePosY);
		Pen.lineTo((centerSquarePosX + (2*centerSquareWidth/3))@(centerSquarePosY + centerSquareHeight));
		Pen.stroke;

		Pen.strokeColor =  Color.new(153/255, 102/255, 0, 0.3);
		Pen.moveTo(centerSquarePosX@(centerSquarePosY + (centerSquareHeight/3)));
		Pen.lineTo((centerSquarePosX + centerSquareWidth)@(centerSquarePosY + (centerSquareHeight/3)));
		Pen.stroke;

		Pen.strokeColor =  Color.new(153/255, 102/255, 0, 0.3);
		Pen.moveTo(centerSquarePosX@(centerSquarePosY + (2*centerSquareHeight/3)));
		Pen.lineTo((centerSquarePosX + centerSquareWidth)@(centerSquarePosY + (2*centerSquareHeight/3)));
		Pen.stroke;

		//-- LDRs outline+fill
		Pen.strokeColor = Color.new(1, 51/255, 0, 0.9);
		Pen.fillColor = Color.new(153/255, 204/255, 1, 0.25);

		Pen.circle(Rect(vecLDRDrawPositions[0].x, vecLDRDrawPositions[0].y, ldrsDiameter, ldrsDiameter));
		Pen.circle(Rect(vecLDRDrawPositions[1].x, vecLDRDrawPositions[1].y, ldrsDiameter, ldrsDiameter));
		Pen.circle(Rect(vecLDRDrawPositions[2].x, vecLDRDrawPositions[2].y, ldrsDiameter, ldrsDiameter));

		Pen.circle(Rect(vecLDRDrawPositions[3].x, vecLDRDrawPositions[3].y, ldrsDiameter, ldrsDiameter));
		Pen.circle(Rect(vecLDRDrawPositions[4].x, vecLDRDrawPositions[4].y, ldrsDiameter, ldrsDiameter));

		Pen.circle(Rect(vecLDRDrawPositions[5].x, vecLDRDrawPositions[5].y, ldrsDiameter, ldrsDiameter));
		Pen.circle(Rect(vecLDRDrawPositions[6].x, vecLDRDrawPositions[6].y, ldrsDiameter, ldrsDiameter));
		Pen.circle(Rect(vecLDRDrawPositions[7].x, vecLDRDrawPositions[7].y, ldrsDiameter, ldrsDiameter));
		Pen.width = 1.75;
		Pen.draw(3);

		//-- LDRs square wave pattern
		Pen.strokeColor = Color.new(1, 51/255, 0, 1);
		curCelcenterSquarePosX = vecLDRDrawPositions[0].x + (ldrsDiameter/7);
		curCelcenterSquarePosY = vecLDRDrawPositions[0].y + (ldrsDiameter/2);
		Pen.moveTo(curCelcenterSquarePosX + 7 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX - 5 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX - 1 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 11 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 15 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 3 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 7 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 19 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 23 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 11 @ curCelcenterSquarePosY + 6);

		curCelcenterSquarePosX = vecLDRDrawPositions[1].x + (ldrsDiameter/7);
		Pen.moveTo(curCelcenterSquarePosX + 7 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX - 5 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX - 1 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 11 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 15 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 3 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 7 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 19 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 23 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 11 @ curCelcenterSquarePosY + 6);

		curCelcenterSquarePosX = vecLDRDrawPositions[2].x + (ldrsDiameter/7);
		Pen.moveTo(curCelcenterSquarePosX + 7 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX - 5 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX - 1 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 11 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 15 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 3 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 7 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 19 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 23 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 11 @ curCelcenterSquarePosY + 6);

		curCelcenterSquarePosX = vecLDRDrawPositions[3].x + (ldrsDiameter/7);
		curCelcenterSquarePosY = vecLDRDrawPositions[3].y + (ldrsDiameter/2);
		Pen.moveTo(curCelcenterSquarePosX + 7 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX - 5 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX - 1 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 11 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 15 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 3 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 7 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 19 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 23 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 11 @ curCelcenterSquarePosY + 6);

		curCelcenterSquarePosX = vecLDRDrawPositions[4].x + (ldrsDiameter/7);
		Pen.moveTo(curCelcenterSquarePosX + 7 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX - 5 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX - 1 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 11 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 15 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 3 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 7 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 19 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 23 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 11 @ curCelcenterSquarePosY + 6);

		curCelcenterSquarePosX = vecLDRDrawPositions[5].x + (ldrsDiameter/7);
		curCelcenterSquarePosY = vecLDRDrawPositions[5].y + (ldrsDiameter/2);
		Pen.moveTo(curCelcenterSquarePosX + 7 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX - 5 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX - 1 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 11 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 15 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 3 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 7 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 19 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 23 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 11 @ curCelcenterSquarePosY + 6);

		curCelcenterSquarePosX = vecLDRDrawPositions[6].x + (ldrsDiameter/7);
		Pen.moveTo(curCelcenterSquarePosX + 7 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX - 5 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX - 1 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 11 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 15 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 3 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 7 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 19 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 23 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 11 @ curCelcenterSquarePosY + 6);

		curCelcenterSquarePosX = vecLDRDrawPositions[7].x + (ldrsDiameter/7);
		Pen.moveTo(curCelcenterSquarePosX + 7 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX - 5 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX - 1 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 11 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 15 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 3 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 7 @ curCelcenterSquarePosY + 6);
		Pen.lineTo(curCelcenterSquarePosX + 19 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 23 @ curCelcenterSquarePosY - 6);
		Pen.lineTo(curCelcenterSquarePosX + 11 @ curCelcenterSquarePosY + 6);
		Pen.width = 1.75;
		Pen.stroke();

		// -- Last Identified LDRPattern Shell
		Pen.strokeColor = Color.new(0.85, 0.85, 0.85, 0.85);
		Pen.moveTo(lastIndentifiedLDRPatternPosX@lastIndentifiedLDRPatternPosY);
		Pen.lineTo(lastIndentifiedLDRPatternPosX + lastIndentifiedLDRPatternLength@lastIndentifiedLDRPatternPosY);
		Pen.lineTo(lastIndentifiedLDRPatternPosX + lastIndentifiedLDRPatternLength@(lastIndentifiedLDRPatternPosY + lastIndentifiedLDRPatternLength));
		Pen.lineTo(lastIndentifiedLDRPatternPosX@(lastIndentifiedLDRPatternPosY + lastIndentifiedLDRPatternLength));
		Pen.lineTo(lastIndentifiedLDRPatternPosX@lastIndentifiedLDRPatternPosY);
		Pen.width = 1;
		Pen.stroke;

		Pen.strokeColor =  Color.new(0.85, 0.85, 0.85, 0.45);
		Pen.moveTo((lastIndentifiedLDRPatternPosX + (lastIndentifiedLDRPatternLength/3))@lastIndentifiedLDRPatternPosY);
		Pen.lineTo((lastIndentifiedLDRPatternPosX + (lastIndentifiedLDRPatternLength/3))@(lastIndentifiedLDRPatternPosY + lastIndentifiedLDRPatternLength));
		Pen.stroke;

		Pen.strokeColor =  Color.new(0.85, 0.85, 0.85, 0.45);
		Pen.moveTo((lastIndentifiedLDRPatternPosX + (2*lastIndentifiedLDRPatternLength/3))@lastIndentifiedLDRPatternPosY);
		Pen.lineTo((lastIndentifiedLDRPatternPosX + (2*lastIndentifiedLDRPatternLength/3))@(lastIndentifiedLDRPatternPosY + lastIndentifiedLDRPatternLength));
		Pen.stroke;

		Pen.strokeColor =  Color.new(0.85, 0.85, 0.85, 0.45);
		Pen.moveTo(lastIndentifiedLDRPatternPosX@(lastIndentifiedLDRPatternPosY + (lastIndentifiedLDRPatternLength/3)));
		Pen.lineTo((lastIndentifiedLDRPatternPosX + lastIndentifiedLDRPatternLength)@(lastIndentifiedLDRPatternPosY + (lastIndentifiedLDRPatternLength/3)));
		Pen.stroke;

		Pen.strokeColor =  Color.new(0.85, 0.85, 0.85, 0.45);
		Pen.moveTo(lastIndentifiedLDRPatternPosX@(lastIndentifiedLDRPatternPosY + (2*lastIndentifiedLDRPatternLength/3)));
		Pen.lineTo((lastIndentifiedLDRPatternPosX + lastIndentifiedLDRPatternLength)@(lastIndentifiedLDRPatternPosY + (2*lastIndentifiedLDRPatternLength/3)));
		Pen.stroke;

		for(0, 5, {
			arg i;
			var horizontalIndexing = 0, verticalIndexing = 0, verticalIndexingMul = 0;

			verticalIndexingMul = (i / 2).asInteger;
			verticalIndexing = verticalIndexingMul * (possibleLDRPatternsLength + (2 * possibleLDRPatternsVerticalDistance));

			if(i % 2 != 0,{
				horizontalIndexing = possibleLDRPatternsLength + possibleLDRPatternsHorizontalDistance;
			});

			Pen.strokeColor = Color.new(0.85, 0.85, 0.85, 0.85);
			Pen.moveTo((possibleLDRPatternsPosX + horizontalIndexing)@(possibleLDRPatternsPosY + verticalIndexing));
			Pen.lineTo((possibleLDRPatternsPosX + horizontalIndexing + possibleLDRPatternsLength)@(possibleLDRPatternsPosY + verticalIndexing));
			Pen.lineTo((possibleLDRPatternsPosX + horizontalIndexing + possibleLDRPatternsLength)@(possibleLDRPatternsPosY  + verticalIndexing + possibleLDRPatternsLength));
			Pen.lineTo((possibleLDRPatternsPosX + horizontalIndexing)@(possibleLDRPatternsPosY + verticalIndexing + possibleLDRPatternsLength));
			Pen.lineTo((possibleLDRPatternsPosX + horizontalIndexing)@(possibleLDRPatternsPosY + verticalIndexing));
			Pen.width = 1;
			Pen.stroke;

			Pen.strokeColor =  Color.new(0.85, 0.85, 0.85, 0.35);
			Pen.moveTo((possibleLDRPatternsPosX + horizontalIndexing + (possibleLDRPatternsLength/3))@(possibleLDRPatternsPosY + verticalIndexing));
			Pen.lineTo((possibleLDRPatternsPosX + horizontalIndexing + (possibleLDRPatternsLength/3))@(possibleLDRPatternsPosY + verticalIndexing + possibleLDRPatternsLength));
			Pen.stroke;

			Pen.strokeColor =  Color.new(0.85, 0.85, 0.85, 0.35);
			Pen.moveTo((possibleLDRPatternsPosX + horizontalIndexing + (2*possibleLDRPatternsLength/3))@(possibleLDRPatternsPosY + verticalIndexing));
			Pen.lineTo((possibleLDRPatternsPosX + horizontalIndexing + (2*possibleLDRPatternsLength/3))@(possibleLDRPatternsPosY + verticalIndexing + possibleLDRPatternsLength));
			Pen.stroke;

			Pen.strokeColor =  Color.new(0.85, 0.85, 0.85, 0.35);
			Pen.moveTo((possibleLDRPatternsPosX + horizontalIndexing)@(possibleLDRPatternsPosY + verticalIndexing + (possibleLDRPatternsLength/3)));
			Pen.lineTo((possibleLDRPatternsPosX + horizontalIndexing + possibleLDRPatternsLength)@(possibleLDRPatternsPosY + verticalIndexing + (possibleLDRPatternsLength/3)));
			Pen.stroke;

			Pen.strokeColor =  Color.new(0.85, 0.85, 0.85, 0.35);
			Pen.moveTo((possibleLDRPatternsPosX + horizontalIndexing)@(possibleLDRPatternsPosY + verticalIndexing + (2*possibleLDRPatternsLength/3)));
			Pen.lineTo((possibleLDRPatternsPosX + horizontalIndexing + possibleLDRPatternsLength)@(possibleLDRPatternsPosY + verticalIndexing + (2*possibleLDRPatternsLength/3)));
			Pen.stroke;
		});
	};

	//--------------- Pin Control Squares
	a0ControlSquare_view = View(~compsBg, Rect.new(centerSquarePosX - 3, centerSquarePosY - 3, (centerSquareWidth/3), (centerSquareHeight/3))).background_(~ldrPatternColors[0]);
	~vecControlSquares = ~vecControlSquares.add(a0ControlSquare_view);

	a1ControlSquare_view = View(~compsBg, Rect.new(centerSquarePosX + (centerSquareWidth/3) - 3, centerSquarePosY - 3, (centerSquareWidth/3), (centerSquareHeight/3))).background_(~ldrPatternColors[0]);
	~vecControlSquares = ~vecControlSquares.add(a1ControlSquare_view);

	a2ControlSquare_view = View(~compsBg, Rect.new(centerSquarePosX + (centerSquareWidth * 2/3) - 3, centerSquarePosY - 3, (centerSquareWidth/3), (centerSquareHeight/3))).background_(~ldrPatternColors[0]);
	~vecControlSquares = ~vecControlSquares.add(a2ControlSquare_view);

	a3ControlSquare_view = View(~compsBg, Rect.new(centerSquarePosX - 3, centerSquarePosY + (centerSquareHeight/3) - 3, (centerSquareWidth/3), (centerSquareHeight/3))).background_(~ldrPatternColors[0]);
	~vecControlSquares = ~vecControlSquares.add(a3ControlSquare_view);

	a4ControlSquare_view = View(~compsBg, Rect.new(centerSquarePosX + (centerSquareWidth * 2/3) - 3, centerSquarePosY + (centerSquareHeight/3) - 3, (centerSquareWidth/3), (centerSquareHeight/3))).background_(~ldrPatternColors[0]);
	~vecControlSquares = ~vecControlSquares.add(a4ControlSquare_view);

	a5ControlSquare_view = View(~compsBg, Rect.new(centerSquarePosX - 3, centerSquarePosY + (centerSquareHeight * 2/3) - 3, (centerSquareWidth/3), (centerSquareHeight/3))).background_(~ldrPatternColors[0]);
	~vecControlSquares = ~vecControlSquares.add(a5ControlSquare_view);

	a6ControlSquare_view = View(~compsBg, Rect.new(centerSquarePosX + (centerSquareWidth/3) - 3, centerSquarePosY + (centerSquareHeight * 2/3) - 3, (centerSquareWidth/3), (centerSquareHeight/3))).background_(~ldrPatternColors[0]);
	~vecControlSquares = ~vecControlSquares.add(a6ControlSquare_view);

	a7ControlSquare_view = View(~compsBg, Rect.new(centerSquarePosX + (centerSquareWidth * 2/3) - 3, centerSquarePosY + (centerSquareHeight * 2/3) - 3, (centerSquareWidth/3), (centerSquareHeight/3))).background_(~ldrPatternColors[0]);
	~vecControlSquares = ~vecControlSquares.add(a7ControlSquare_view);

	//--------------- Pin Headers
	a0Header_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[0].x, vecLDRDrawPositions[0].y - (2 * ~textSizeGeneral) , ~textSizeGeneral * 2, ~textSizeGeneral * 2))
	.font_(Font("Avenir Next", ~textSizeGeneral, true))
	.align_(\left)
	.stringColor_(Color.new(0.95,0.95,0.95,0.85))
	.string_("A0");

	a1Header_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[1].x, vecLDRDrawPositions[1].y - (2 * ~textSizeGeneral) , ~textSizeGeneral * 2, ~textSizeGeneral * 2))
	.font_(Font("Avenir Next", ~textSizeGeneral, true))
	.align_(\left)
	.stringColor_(Color.new(0.95,0.95,0.95,0.85))
	.string_("A1");

	a2Header_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[2].x, vecLDRDrawPositions[2].y - (2 * ~textSizeGeneral) , ~textSizeGeneral * 2, ~textSizeGeneral * 2))
	.font_(Font("Avenir Next", ~textSizeGeneral, true))
	.align_(\left)
	.stringColor_(Color.new(0.95,0.95,0.95,0.85))
	.string_("A2");

	a3Header_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[3].x, vecLDRDrawPositions[3].y - (2 * ~textSizeGeneral) , ~textSizeGeneral * 2, ~textSizeGeneral * 2))
	.font_(Font("Avenir Next", ~textSizeGeneral, true))
	.align_(\left)
	.stringColor_(Color.new(153/255, 102/255, 0, 0.7))
	.string_("A3");

	a4Header_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[4].x, vecLDRDrawPositions[4].y - (2 * ~textSizeGeneral) , ~textSizeGeneral * 2, ~textSizeGeneral * 2))
	.font_(Font("Avenir Next", ~textSizeGeneral, true))
	.align_(\left)
	.stringColor_(Color.new(153/255, 102/255, 0, 0.7))
	.string_("A4");

	a5Header_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[5].x, vecLDRDrawPositions[5].y - (2 * ~textSizeGeneral) , ~textSizeGeneral * 2, ~textSizeGeneral * 2))
	.font_(Font("Avenir Next", ~textSizeGeneral, true))
	.align_(\left)
	.stringColor_(Color.new(51/255, 51/255, 1, 0.7))
	.string_("A5");

	a6Header_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[6].x, vecLDRDrawPositions[6].y - (2 * ~textSizeGeneral) , ~textSizeGeneral * 2, ~textSizeGeneral * 2))
	.font_(Font("Avenir Next", ~textSizeGeneral, true))
	.align_(\left)
	.stringColor_(Color.new(51/255, 51/255, 1, 0.7))
	.string_("A6");

	a7Header_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[7].x, vecLDRDrawPositions[7].y - (2 * ~textSizeGeneral) , ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Avenir Next", ~textSizeGeneral, true))
	.align_(\left)
	.stringColor_(Color.new(51/255, 51/255, 1, 0.7))
	.string_("A7");


	//--------------- Pin Values
	a0Value_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[0].x - (~textSizeGeneral*0.9), vecLDRDrawPositions[0].y + (1.25 * ~textSizeGeneral) , ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 1, true))
	.align_(\right)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("0000");
	~vecPinValuesStaticText = ~vecPinValuesStaticText.add(a0Value_staticText);

	a1Value_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[1].x - (~textSizeGeneral*0.9), vecLDRDrawPositions[1].y + (1.25 * ~textSizeGeneral) , ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 1, true))
	.align_(\right)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("0000");
	~vecPinValuesStaticText = ~vecPinValuesStaticText.add(a1Value_staticText);

	a2Value_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[2].x - (~textSizeGeneral*0.9), vecLDRDrawPositions[2].y + (1.25 * ~textSizeGeneral) , ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 1, true))
	.align_(\right)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("0000");
	~vecPinValuesStaticText = ~vecPinValuesStaticText.add(a2Value_staticText);

	a3Value_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[3].x - (~textSizeGeneral*0.9), vecLDRDrawPositions[3].y + (1.25 * ~textSizeGeneral) , ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 1, true))
	.align_(\right)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("0000");
	~vecPinValuesStaticText = ~vecPinValuesStaticText.add(a3Value_staticText);

	a4Value_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[4].x - (~textSizeGeneral*0.9), vecLDRDrawPositions[4].y + (1.25 * ~textSizeGeneral) , ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 1, true))
	.align_(\right)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("0000");
	~vecPinValuesStaticText = ~vecPinValuesStaticText.add(a4Value_staticText);

	a5Value_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[5].x - (~textSizeGeneral*0.9), vecLDRDrawPositions[5].y + (1.25 * ~textSizeGeneral) , ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 1, true))
	.align_(\right)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("0000");
	~vecPinValuesStaticText = ~vecPinValuesStaticText.add(a5Value_staticText);

	a6Value_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[6].x - (~textSizeGeneral*0.9), vecLDRDrawPositions[6].y + (1.25 * ~textSizeGeneral) , ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 1, true))
	.align_(\right)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("0000");
	~vecPinValuesStaticText = ~vecPinValuesStaticText.add(a6Value_staticText);

	a7Value_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[7].x - (~textSizeGeneral*0.9), vecLDRDrawPositions[7].y + (1.25 * ~textSizeGeneral) , ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 1, true))
	.align_(\right)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("0000");
	~vecPinValuesStaticText = ~vecPinValuesStaticText.add(a7Value_staticText);

	//---------------Pin Control Values
	a0ControlValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[0].x - (3 * ~textSizeGeneral), vecLDRDrawPositions[0].y - (0.35 * ~textSizeGeneral), ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 3, true))
	.align_(\right)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("");
	~vecPinControlAvaragesStaticText = ~vecPinControlAvaragesStaticText.add(a0ControlValue_staticText);

	a1ControlValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[1].x - (3 * ~textSizeGeneral), vecLDRDrawPositions[1].y - (0.35 * ~textSizeGeneral), ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 3, true))
	.align_(\right)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("");
	~vecPinControlAvaragesStaticText = ~vecPinControlAvaragesStaticText.add(a1ControlValue_staticText);

	a2ControlValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[2].x - (3 * ~textSizeGeneral), vecLDRDrawPositions[2].y - (0.35 * ~textSizeGeneral), ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 3, true))
	.align_(\right)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("");
	~vecPinControlAvaragesStaticText = ~vecPinControlAvaragesStaticText.add(a2ControlValue_staticText);

	a3ControlValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[3].x - (3 * ~textSizeGeneral), vecLDRDrawPositions[3].y - (0.35 * ~textSizeGeneral), ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 3, true))
	.align_(\right)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("");
	~vecPinControlAvaragesStaticText = ~vecPinControlAvaragesStaticText.add(a3ControlValue_staticText);

	a4ControlValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[4].x - (3 * ~textSizeGeneral), vecLDRDrawPositions[4].y - (0.35 * ~textSizeGeneral), ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 4, true))
	.align_(\right)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("");
	~vecPinControlAvaragesStaticText = ~vecPinControlAvaragesStaticText.add(a4ControlValue_staticText);

	a5ControlValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[5].x - (3 * ~textSizeGeneral), vecLDRDrawPositions[5].y - (0.35 * ~textSizeGeneral), ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 3, true))
	.align_(\right)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("");
	~vecPinControlAvaragesStaticText = ~vecPinControlAvaragesStaticText.add(a5ControlValue_staticText);

	a6ControlValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[6].x - (3 * ~textSizeGeneral), vecLDRDrawPositions[6].y - (0.35 * ~textSizeGeneral), ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 3, true))
	.align_(\right)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("");
	~vecPinControlAvaragesStaticText = ~vecPinControlAvaragesStaticText.add(a6ControlValue_staticText);

	a7ControlValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[7].x - (3 * ~textSizeGeneral), vecLDRDrawPositions[7].y - (0.35 * ~textSizeGeneral), ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 3, true))
	.align_(\right)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("");
	~vecPinControlAvaragesStaticText = ~vecPinControlAvaragesStaticText.add(a7ControlValue_staticText);

	//---------------Pin Top Values
	a0TopValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[0].x + (1.2 * ~textSizeGeneral), vecLDRDrawPositions[0].y - ~textSizeGeneral, ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 3, true))
	.align_(\right)
	.stringColor_(Color.new(0.95,0.65,0.65,0.7))
	.string_("");
	~vecPinTopAvaragesStaticText = ~vecPinTopAvaragesStaticText.add(a0TopValue_staticText);

	a1TopValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[1].x + (1.2 * ~textSizeGeneral), vecLDRDrawPositions[1].y - ~textSizeGeneral, ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 3, true))
	.align_(\right)
	.stringColor_(Color.new(0.95,0.65,0.65,0.7))
	.string_("");
	~vecPinTopAvaragesStaticText = ~vecPinTopAvaragesStaticText.add(a1TopValue_staticText);

	a2TopValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[2].x + (1.2 * ~textSizeGeneral), vecLDRDrawPositions[2].y - ~textSizeGeneral, ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 3, true))
	.align_(\right)
	.stringColor_(Color.new(0.95,0.65,0.65,0.7))
	.string_("");
	~vecPinTopAvaragesStaticText = ~vecPinTopAvaragesStaticText.add(a2TopValue_staticText);

	a3TopValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[3].x + (1.2 * ~textSizeGeneral), vecLDRDrawPositions[3].y - ~textSizeGeneral, ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 3, true))
	.align_(\right)
	.stringColor_(Color.new(0.95,0.65,0.65,0.7))
	.string_("");
	~vecPinTopAvaragesStaticText = ~vecPinTopAvaragesStaticText.add(a3TopValue_staticText);

	a4TopValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[4].x + (1.2 * ~textSizeGeneral), vecLDRDrawPositions[4].y - ~textSizeGeneral, ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 4, true))
	.align_(\right)
	.stringColor_(Color.new(0.95,0.65,0.65,0.7))
	.string_("");
	~vecPinTopAvaragesStaticText = ~vecPinTopAvaragesStaticText.add(a4TopValue_staticText);

	a5TopValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[5].x + (1.2 * ~textSizeGeneral), vecLDRDrawPositions[5].y - ~textSizeGeneral, ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 3, true))
	.align_(\right)
	.stringColor_(Color.new(0.95,0.65,0.65,0.7))
	.string_("");
	~vecPinTopAvaragesStaticText = ~vecPinTopAvaragesStaticText.add(a5TopValue_staticText);

	a6TopValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[6].x + (1.2 * ~textSizeGeneral), vecLDRDrawPositions[6].y - ~textSizeGeneral, ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 3, true))
	.align_(\right)
	.stringColor_(Color.new(0.95,0.65,0.65,0.7))
	.string_("");
	~vecPinTopAvaragesStaticText = ~vecPinTopAvaragesStaticText.add(a6TopValue_staticText);

	a7TopValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[7].x + (1.2 * ~textSizeGeneral), vecLDRDrawPositions[7].y - ~textSizeGeneral, ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 3, true))
	.align_(\right)
	.stringColor_(Color.new(0.95,0.65,0.65,0.7))
	.string_("");
	~vecPinTopAvaragesStaticText = ~vecPinTopAvaragesStaticText.add(a7TopValue_staticText);

	//---------------Pin Bottom Values
	a0BottomValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[0].x + (1.2 * ~textSizeGeneral), vecLDRDrawPositions[0].y, ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 3, true))
	.align_(\right)
	.stringColor_(Color.new(0.65,0.65,0.95,0.7))
	.string_("");
	~vecPinBottomAvaragesStaticText = ~vecPinBottomAvaragesStaticText.add(a0BottomValue_staticText);

	a1BottomValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[1].x + (1.2 * ~textSizeGeneral), vecLDRDrawPositions[1].y, ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 3, true))
	.align_(\right)
	.stringColor_(Color.new(0.65,0.65,0.95,0.7))
	.string_("");
	~vecPinBottomAvaragesStaticText = ~vecPinBottomAvaragesStaticText.add(a1BottomValue_staticText);

	a2BottomValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[2].x + (1.2 * ~textSizeGeneral), vecLDRDrawPositions[2].y, ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 3, true))
	.align_(\right)
	.stringColor_(Color.new(0.65,0.65,0.95,0.7))
	.string_("");
	~vecPinBottomAvaragesStaticText = ~vecPinBottomAvaragesStaticText.add(a2BottomValue_staticText);

	a3BottomValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[3].x + (1.2 * ~textSizeGeneral), vecLDRDrawPositions[3].y, ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 3, true))
	.align_(\right)
	.stringColor_(Color.new(0.65,0.65,0.95,0.7))
	.string_("");
	~vecPinBottomAvaragesStaticText = ~vecPinBottomAvaragesStaticText.add(a3BottomValue_staticText);

	a4BottomValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[4].x + (1.2 * ~textSizeGeneral), vecLDRDrawPositions[4].y, ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 4, true))
	.align_(\right)
	.stringColor_(Color.new(0.65,0.65,0.95,0.7))
	.string_("");
	~vecPinBottomAvaragesStaticText = ~vecPinBottomAvaragesStaticText.add(a4BottomValue_staticText);

	a5BottomValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[5].x + (1.2 * ~textSizeGeneral), vecLDRDrawPositions[5].y, ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 3, true))
	.align_(\right)
	.stringColor_(Color.new(0.65,0.65,0.95,0.7))
	.string_("");
	~vecPinBottomAvaragesStaticText = ~vecPinBottomAvaragesStaticText.add(a5BottomValue_staticText);

	a6BottomValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[6].x + (1.2 * ~textSizeGeneral), vecLDRDrawPositions[6].y, ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 3, true))
	.align_(\right)
	.stringColor_(Color.new(0.65,0.65,0.95,0.7))
	.string_("");
	~vecPinBottomAvaragesStaticText = ~vecPinBottomAvaragesStaticText.add(a6BottomValue_staticText);

	a7BottomValue_staticText = StaticText.new(~compsBg, Rect(vecLDRDrawPositions[7].x + (1.2 * ~textSizeGeneral), vecLDRDrawPositions[7].y, ~textSizeGeneral * 2.5, ~textSizeGeneral * 2))
	.font_(Font("Courier New", ~textSizeGeneral - 3, true))
	.align_(\right)
	.stringColor_(Color.new(0.65,0.65,0.95,0.7))
	.string_("");
	~vecPinBottomAvaragesStaticText = ~vecPinBottomAvaragesStaticText.add(a7BottomValue_staticText);

	//--------------- Buttons
	buttonIndexingPoint = Point.new(shellMarginWidth*2, centerSquarePosY - (~textSizeGeneral));
	//--- Control Value Avarage
	avarageControlValues_button = Button.new(~compsBg, Rect(shellMarginWidth*2, buttonIndexingPoint.y, ~textSizeGeneral * 0.9, ~textSizeGeneral * 0.9))
	.states_([
		["", Color.white, Color.new(0.4, 0.4, 0.2, 0.7)],
		["", Color.white, Color.new(1, 1, 0.3, 0.85)]
	]).action_({
		arg self;

		if(self.value == 1, {
			~funcStartAvaraging.value();
		}, {
			~funcGenerateAvarages.value();
			showAvarageControlValues_button.valueAction = 1;
		});
	});

	avarageControlValues_buttonHeader = StaticText.new(~compsBg, Rect(shellMarginWidth*2.4, buttonIndexingPoint.y, ~textSizeGeneral * 30, ~textSizeGeneral))
	.font_(Font("Courier New", ~textSizeGeneral - 2, true))
	.align_(\left)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("generate control avarage values");

	showAvarageControlValues_button = Button.new(~compsBg, Rect(shellMarginWidth*2, buttonIndexingPoint.y  + (2*~textSizeGeneral), ~textSizeGeneral * 0.9, ~textSizeGeneral * 0.9))
	.states_([
		["", Color.white, Color.new(0.4, 0.4, 0.2, 0.7)],
		["", Color.white, Color.new(1, 1, 0.3, 0.85)]
	]).action_({
		arg self;

		if(self.value == 1, {
			~funcShowHideValues.value(true);
		}, {
			~funcShowHideValues.value(false);
		});
	});

	showAvarageControlValues_buttonHeader = StaticText.new(~compsBg, Rect(shellMarginWidth*2.4, buttonIndexingPoint.y + (2*~textSizeGeneral), ~textSizeGeneral * 30, ~textSizeGeneral))
	.font_(Font("Courier New", ~textSizeGeneral - 2, true))
	.align_(\left)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("show control avaraged values");

	//--- Values Top
	setValuesTop_button = Button.new(~compsBg, Rect(shellMarginWidth*2, buttonIndexingPoint.y + (5*~textSizeGeneral), ~textSizeGeneral * 0.9, ~textSizeGeneral * 0.9))
	.states_([
		["", Color.white, Color.new(0.3, 0.2, 0.2, 0.7)],
		["", Color.white, Color.new(1, 0.2, 0.2, 0.85)]
	]).action_({
		arg self;

		if(self.value == 1, {
			~funcStartAvaraging.value();
		}, {
			~funcGenerateAvarages.value(avarageType:1);
			showValuesTop_button.valueAction = 1;
		});
	});

	setValuesTop_buttonHeader = StaticText.new(~compsBg, Rect(shellMarginWidth*2.4, buttonIndexingPoint.y + (5*~textSizeGeneral), ~textSizeGeneral * 30, ~textSizeGeneral))
	.font_(Font("Courier New", ~textSizeGeneral - 2, true))
	.align_(\left)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("set values top");

	showValuesTop_button = Button.new(~compsBg, Rect(shellMarginWidth*2, buttonIndexingPoint.y + (7*~textSizeGeneral), ~textSizeGeneral * 0.9, ~textSizeGeneral * 0.9))
	.states_([
		["", Color.white, Color.new(0.3, 0.2, 0.2, 0.7)],
		["", Color.white, Color.new(1, 0.2, 0.2, 0.85)]
	]).action_({
		arg self;

		if(self.value == 1, {
			~funcShowHideValues.value(showValue: true, valueType: 1);
		}, {
			~funcShowHideValues.value(showValue: false, valueType: 1);
		});
	});

	showValuesTop_buttonHeader = StaticText.new(~compsBg, Rect(shellMarginWidth*2.4, buttonIndexingPoint.y + (7*~textSizeGeneral), ~textSizeGeneral * 30, ~textSizeGeneral))
	.font_(Font("Courier New", ~textSizeGeneral - 2, true))
	.align_(\left)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("show values top");

	//--- Values Bottom
	setValuesBottom_button = Button.new(~compsBg, Rect(shellMarginWidth*2, buttonIndexingPoint.y + (10*~textSizeGeneral), ~textSizeGeneral * 0.9, ~textSizeGeneral * 0.9))
	.states_([
		["", Color.white, Color.new(0.2, 0.2, 0.3, 0.7)],
		["", Color.white, Color.new(0.2, 0.2, 1, 0.85)]
	]).action_({
		arg self;

		if(self.value == 1, {
			~funcStartAvaraging.value();
		}, {
			~funcGenerateAvarages.value(avarageType:2);
			showValuesBottom_button.valueAction = 1;
		});
	});

	setValuesBottom_buttonHeader = StaticText.new(~compsBg, Rect(shellMarginWidth*2.4, buttonIndexingPoint.y + (10*~textSizeGeneral), ~textSizeGeneral * 30, ~textSizeGeneral))
	.font_(Font("Courier New", ~textSizeGeneral - 2, true))
	.align_(\left)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("set values bottom");

	showValuesBottom_button = Button.new(~compsBg, Rect(shellMarginWidth*2, buttonIndexingPoint.y + (12*~textSizeGeneral), ~textSizeGeneral * 0.9, ~textSizeGeneral * 0.9))
	.states_([
		["", Color.white, Color.new(0.2, 0.2, 0.3, 0.7)],
		["", Color.white, Color.new(0.2, 0.2, 1, 0.85)]
	]).action_({
		arg self;

		if(self.value == 1, {
			~funcShowHideValues.value(showValue: true, valueType: 2);
		}, {
			~funcShowHideValues.value(showValue: false, valueType: 2);
		});
	});

	showValuesBottom_buttonHeader = StaticText.new(~compsBg, Rect(shellMarginWidth*2.4, buttonIndexingPoint.y + (12*~textSizeGeneral), ~textSizeGeneral * 30, ~textSizeGeneral))
	.font_(Font("Courier New", ~textSizeGeneral - 2, true))
	.align_(\left)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("show values bottom");

	//--- Post Values
	buttonIndexingPoint = Point.new(shellMarginWidth*2, centerSquarePosY + centerSquareHeight - (~textSizeGeneral/2));
	postValues_button = Button.new(~compsBg, Rect(shellMarginWidth*2, buttonIndexingPoint.y, ~textSizeGeneral * 0.9, ~textSizeGeneral * 0.9))
	.states_([
		["", Color.white, Color.new(0.6, 0.6, 0.6, 0.5)],
		["", Color.white, Color.new(0.99, 0.99, 0.99, 0.85)]
	]).action_({
		arg self;

		if(self.value == 1, {
			~postValues = true;
		}, {
			~postValues = false;
		});
	});

	postValues_buttonHeader = StaticText.new(~compsBg, Rect(shellMarginWidth*2.4, buttonIndexingPoint.y, ~textSizeGeneral * 30, ~textSizeGeneral))
	.font_(Font("Courier New", ~textSizeGeneral - 2, true))
	.align_(\left)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("post all incoming values");

	// --- Start Button
	buttonIndexingPoint = Point.new(centerSquarePosX + (centerSquareWidth/3), centerSquarePosY + centerSquareHeight + ~textSizeGeneral);
	start_button = Button.new(~compsBg, Rect(buttonIndexingPoint.x, buttonIndexingPoint.y, ~textSizeGeneral * 0.9, ~textSizeGeneral * 0.9))
	.states_([
		["", Color.white, Color.new(0.2, 0.45, 0.2, 0.7)],
		["", Color.white, Color.new(0.2, 1, 0.2, 0.85)]
	]).action_({
		arg self;

		if(self.value == 1, {
			~funcStartCaminhooculto.value();
		}, {
			~taskUpdatePossibleLDRPatterns.stop;
			~taskUpdatePossiblePatternsDuration.stop;
		});
	});

	start_buttonHeader = StaticText.new(~compsBg, Rect(buttonIndexingPoint.x + (shellMarginWidth*0.4), buttonIndexingPoint.y, ~textSizeGeneral * 30, ~textSizeGeneral))
	.font_(Font("Courier New", ~textSizeGeneral - 2, true))
	.align_(\left)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("start caminhooculto");

	//--------------- LDRPattern Identifications
	// --- Last Identified LDRPattern
	lastIdentifiedLDRPattern_header = StaticText.new(~compsBg, Rect(lastIndentifiedLDRPatternPosX + (shellMarginWidth/2), lastIndentifiedLDRPatternPosY - (shellMarginWidth/2), ~textSizeGeneral * 30, ~textSizeGeneral))
	.font_(Font("Courier New", ~textSizeGeneral - 2, true))
	.align_(\left)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("last pattern identified");

	lastIdentifiedLDRPatternProcessTriggered_header = StaticText.new(~compsBg, Rect(lastIndentifiedLDRPatternPosX , lastIndentifiedLDRPatternPosY + lastIndentifiedLDRPatternLength, ~textSizeGeneral * 16, ~textSizeGeneral))
	.font_(Font("Courier New", ~textSizeGeneral - 2, true))
	.align_(\center)
	.stringColor_(Color.new(0.75,0.85,0.85,0.7))
	.string_("process triggered: ");

	lastIdentifiedLDRPatternProcessTriggered_text = StaticText.new(~compsBg, Rect(lastIndentifiedLDRPatternPosX, lastIndentifiedLDRPatternPosY + lastIndentifiedLDRPatternLength + (shellMarginWidth/4), ~textSizeGeneral * 15, ~textSizeGeneral))
	.font_(Font("Courier New", ~textSizeGeneral - 2, true))
	.align_(\center)
	.stringColor_(Color.new(0.65,0.95,0.75,0.75))
	.string_("none");
	~vecLastIndentifiedLDRPatternObjs = ~vecLastIndentifiedLDRPatternObjs.add(lastIdentifiedLDRPatternProcessTriggered_text);

	//--- Last Identified LDRPattern Squares
	lastIndentifiedLDRPatternSquaresHorizontalIndex = lastIndentifiedLDRPatternPosX - margin;
	lastIndentifiedLDRPatternSquaresVerticalIndex = lastIndentifiedLDRPatternPosY - margin;
	lastIdentifiedLDRPattern_A0View = View(~compsBg, Rect.new(lastIndentifiedLDRPatternSquaresHorizontalIndex + 1, lastIndentifiedLDRPatternSquaresVerticalIndex + 1, (lastIndentifiedLDRPatternLength/3) - 2, (lastIndentifiedLDRPatternLength/3) - 2)).background_(~ldrPatternColors[0]);
	~vecLastIndentifiedLDRPatternObjs = ~vecLastIndentifiedLDRPatternObjs.add(lastIdentifiedLDRPattern_A0View);

	lastIndentifiedLDRPatternSquaresHorizontalIndex = lastIndentifiedLDRPatternSquaresHorizontalIndex + (lastIndentifiedLDRPatternLength/3);
	lastIdentifiedLDRPattern_A1View = View(~compsBg, Rect.new(lastIndentifiedLDRPatternSquaresHorizontalIndex + 1, lastIndentifiedLDRPatternSquaresVerticalIndex + 1, (lastIndentifiedLDRPatternLength/3) - 2, (lastIndentifiedLDRPatternLength/3) - 2)).background_(~ldrPatternColors[0]);
	~vecLastIndentifiedLDRPatternObjs = ~vecLastIndentifiedLDRPatternObjs.add(lastIdentifiedLDRPattern_A1View);

	lastIndentifiedLDRPatternSquaresHorizontalIndex = lastIndentifiedLDRPatternSquaresHorizontalIndex + (lastIndentifiedLDRPatternLength/3);
	lastIdentifiedLDRPattern_A2View = View(~compsBg, Rect.new(lastIndentifiedLDRPatternSquaresHorizontalIndex + 1, lastIndentifiedLDRPatternSquaresVerticalIndex + 1, (lastIndentifiedLDRPatternLength/3) - 2, (lastIndentifiedLDRPatternLength/3) - 2)).background_(~ldrPatternColors[0]);
	~vecLastIndentifiedLDRPatternObjs = ~vecLastIndentifiedLDRPatternObjs.add(lastIdentifiedLDRPattern_A2View);

	lastIndentifiedLDRPatternSquaresHorizontalIndex = lastIndentifiedLDRPatternPosX - margin;
	lastIndentifiedLDRPatternSquaresVerticalIndex = lastIndentifiedLDRPatternSquaresVerticalIndex + (lastIndentifiedLDRPatternLength/3);
	lastIdentifiedLDRPattern_A3View = View(~compsBg, Rect.new(lastIndentifiedLDRPatternSquaresHorizontalIndex + 1, lastIndentifiedLDRPatternSquaresVerticalIndex + 1, (lastIndentifiedLDRPatternLength/3) - 2, (lastIndentifiedLDRPatternLength/3) - 2)).background_(~ldrPatternColors[0]);
	~vecLastIndentifiedLDRPatternObjs = ~vecLastIndentifiedLDRPatternObjs.add(lastIdentifiedLDRPattern_A3View);

	lastIndentifiedLDRPatternSquaresHorizontalIndex = lastIndentifiedLDRPatternSquaresHorizontalIndex + (2*lastIndentifiedLDRPatternLength/3);
	lastIdentifiedLDRPattern_A4View = View(~compsBg, Rect.new(lastIndentifiedLDRPatternSquaresHorizontalIndex + 1, lastIndentifiedLDRPatternSquaresVerticalIndex + 1, (lastIndentifiedLDRPatternLength/3) - 2, (lastIndentifiedLDRPatternLength/3) - 2)).background_(~ldrPatternColors[0]);
	~vecLastIndentifiedLDRPatternObjs = ~vecLastIndentifiedLDRPatternObjs.add(lastIdentifiedLDRPattern_A4View);

	lastIndentifiedLDRPatternSquaresHorizontalIndex = lastIndentifiedLDRPatternPosX - margin;
	lastIndentifiedLDRPatternSquaresVerticalIndex = lastIndentifiedLDRPatternSquaresVerticalIndex + (lastIndentifiedLDRPatternLength/3);
	lastIdentifiedLDRPattern_A5View = View(~compsBg, Rect.new(lastIndentifiedLDRPatternSquaresHorizontalIndex + 1, lastIndentifiedLDRPatternSquaresVerticalIndex + 1, (lastIndentifiedLDRPatternLength/3) - 2, (lastIndentifiedLDRPatternLength/3) - 2)).background_(~ldrPatternColors[0]);
	~vecLastIndentifiedLDRPatternObjs = ~vecLastIndentifiedLDRPatternObjs.add(lastIdentifiedLDRPattern_A5View);

	lastIndentifiedLDRPatternSquaresHorizontalIndex = lastIndentifiedLDRPatternSquaresHorizontalIndex + (lastIndentifiedLDRPatternLength/3);
	lastIdentifiedLDRPattern_A6View = View(~compsBg, Rect.new(lastIndentifiedLDRPatternSquaresHorizontalIndex + 1, lastIndentifiedLDRPatternSquaresVerticalIndex + 1, (lastIndentifiedLDRPatternLength/3) - 2, (lastIndentifiedLDRPatternLength/3) - 2)).background_(~ldrPatternColors[0]);
	~vecLastIndentifiedLDRPatternObjs = ~vecLastIndentifiedLDRPatternObjs.add(lastIdentifiedLDRPattern_A6View);

	lastIndentifiedLDRPatternSquaresHorizontalIndex = lastIndentifiedLDRPatternSquaresHorizontalIndex + (lastIndentifiedLDRPatternLength/3);
	lastIdentifiedLDRPattern_A7View = View(~compsBg, Rect.new(lastIndentifiedLDRPatternSquaresHorizontalIndex + 1, lastIndentifiedLDRPatternSquaresVerticalIndex + 1, (lastIndentifiedLDRPatternLength/3) - 2, (lastIndentifiedLDRPatternLength/3) - 2)).background_(~ldrPatternColors[0]);
	~vecLastIndentifiedLDRPatternObjs = ~vecLastIndentifiedLDRPatternObjs.add(lastIdentifiedLDRPattern_A7View);

	//--- Current Possible LDRPatterns
	possibleLDRPatterns_header = StaticText.new(~compsBg, Rect(possibleLDRPatternsPosX + (shellMarginWidth), possibleLDRPatternsPosY - (shellMarginWidth/1.1), ~textSizeGeneral * 30, ~textSizeGeneral))
	.font_(Font("Courier New", ~textSizeGeneral - 2, true))
	.align_(\left)
	.stringColor_(Color.new(0.75,0.85,0.85,0.8))
	.string_("current possible patterns");

	//--- Possible LDRPatterns Squares
	{
		for(0, 5, {
			arg i;
			var horizontalIndexing = possibleLDRPatternsPosX,
		        verticalIndexing = 0,
			    verticalIndexingMul = 0,
			    possibleLDRPatternProcessToTrigger_text,
			    possibleLDRPattern_A0View,
			    possibleLDRPattern_A1View,
			    possibleLDRPattern_A2View,
			    possibleLDRPattern_A3View,
			    possibleLDRPattern_A4View,
			    possibleLDRPattern_A5View,
			    possibleLDRPattern_A6View,
			    possibleLDRPattern_A7View,
			    vecPossibleLDRPatterns = []
			;

			verticalIndexingMul = (i / 2).asInteger;
			verticalIndexing = possibleLDRPatternsPosY + (verticalIndexingMul * (possibleLDRPatternsLength + (2 * possibleLDRPatternsVerticalDistance)));

			if(i % 2 != 0,{
				horizontalIndexing = possibleLDRPatternsPosX + possibleLDRPatternsLength + possibleLDRPatternsHorizontalDistance;
			});

			possibleLDRPatternProcessToTrigger_text = StaticText.new(~compsBg, Rect(horizontalIndexing, verticalIndexing - (1.5 * ~textSizeGeneral), possibleLDRPatternsLength, ~textSizeGeneral))
			.font_(Font("Courier New", ~textSizeGeneral - 2, true))
			.align_(\center)
			.stringColor_(Color.new(0.65,0.95,0.75,0.75))
			.string_("process");
			vecPossibleLDRPatterns = vecPossibleLDRPatterns.add(possibleLDRPatternProcessToTrigger_text);

			possibleLDRPattern_A0View = View(~compsBg, Rect.new(horizontalIndexing - 2.5, verticalIndexing - 2.5, (possibleLDRPatternsLength/3), (possibleLDRPatternsLength/3)))
			.background_(~ldrPatternColors[0]);
			vecPossibleLDRPatterns = vecPossibleLDRPatterns.add(possibleLDRPattern_A0View);

			possibleLDRPattern_A1View = View(~compsBg, Rect.new(horizontalIndexing + (possibleLDRPatternsLength/3) - 2.5, verticalIndexing - 2.5, (possibleLDRPatternsLength/3), (possibleLDRPatternsLength/3)))
			.background_(~ldrPatternColors[0]);
			vecPossibleLDRPatterns = vecPossibleLDRPatterns.add(possibleLDRPattern_A1View);

			possibleLDRPattern_A2View = View(~compsBg, Rect.new(horizontalIndexing + (possibleLDRPatternsLength* 2/3) - 2.5, verticalIndexing - 2.5, (possibleLDRPatternsLength/3), (possibleLDRPatternsLength/3)))
			.background_(~ldrPatternColors[0]);
			vecPossibleLDRPatterns = vecPossibleLDRPatterns.add(possibleLDRPattern_A2View);

			possibleLDRPattern_A3View = View(~compsBg, Rect.new(horizontalIndexing - 2.5, verticalIndexing + (possibleLDRPatternsLength/3) - 2.5, (possibleLDRPatternsLength/3), (possibleLDRPatternsLength/3)))
			.background_(~ldrPatternColors[0]);
			vecPossibleLDRPatterns = vecPossibleLDRPatterns.add(possibleLDRPattern_A3View);

			possibleLDRPattern_A4View = View(~compsBg, Rect.new(horizontalIndexing + (possibleLDRPatternsLength* 2/3) - 2.5, verticalIndexing + (possibleLDRPatternsLength/3) - 2.5, (possibleLDRPatternsLength/3), (possibleLDRPatternsLength/3)))
			.background_(~ldrPatternColors[0]);
			vecPossibleLDRPatterns = vecPossibleLDRPatterns.add(possibleLDRPattern_A4View);

			possibleLDRPattern_A5View = View(~compsBg, Rect.new(horizontalIndexing - 2.5, verticalIndexing + (possibleLDRPatternsLength* 2/3) - 2.5, (possibleLDRPatternsLength/3), (possibleLDRPatternsLength/3)))
			.background_(~ldrPatternColors[0]);
			vecPossibleLDRPatterns = vecPossibleLDRPatterns.add(possibleLDRPattern_A5View);

			possibleLDRPattern_A6View = View(~compsBg, Rect.new(horizontalIndexing + (possibleLDRPatternsLength/3) - 2.5, verticalIndexing + (possibleLDRPatternsLength* 2/3) - 2.5, (possibleLDRPatternsLength/3), (possibleLDRPatternsLength/3)))
			.background_(~ldrPatternColors[0]);
			vecPossibleLDRPatterns = vecPossibleLDRPatterns.add(possibleLDRPattern_A6View);

			possibleLDRPattern_A7View = View(~compsBg, Rect.new(horizontalIndexing + (possibleLDRPatternsLength* 2/3) - 2.5, verticalIndexing + (possibleLDRPatternsLength* 2/3) - 2.5, (possibleLDRPatternsLength/3), (possibleLDRPatternsLength/3)))
			.background_(~ldrPatternColors[0]);
			vecPossibleLDRPatterns = vecPossibleLDRPatterns.add(possibleLDRPattern_A7View);

			~vecPossibleLDRPatternsObjs = ~vecPossibleLDRPatternsObjs.add(vecPossibleLDRPatterns);
		});
	}.fork(AppClock);

	~possibleLDRPatternsDuration_text = StaticText.new(~compsBg, Rect(possibleLDRPatternsPosX, possibleLDRPatternsPosY + (3 * (possibleLDRPatternsLength + (2 * possibleLDRPatternsVerticalDistance) - (shellMarginWidth/6))), (2*possibleLDRPatternsLength) + possibleLDRPatternsHorizontalDistance, ~textSizeGeneral * 1.1))
	.font_(Font("Courier New", ~textSizeGeneral * 1.1, true))
	.align_(\center)
	.stringColor_(Color.new(0.6, 0.6, 0.3, 0.85))
	.string_("0.000");
});
)