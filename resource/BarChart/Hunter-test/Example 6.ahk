;===Auto-execute========================================================================
ChartData =
(
1526.43
1524.53
1523.65
1522.6
1521.03
1517.92
1515.43
1513.4
1512.12
1510.3
1506.85
1505.97
1506.22
1507.32
1507.53
1507.67
1507.63
1508.1
1509.03
1509.4
1509.87
1510.68
1510.6
1511.97
1512.55
1515.28
1518.58
1522.22
1526.45
1530.37
1536.2
1544.9
1551.92
1559.37
1567.73
1574.9
1581.82
1588.38
1595.23
1601.18
1608.37
1614.28
1621.02
1629.95
1638.88
1648.13
1653.52
1657.98
1660.0
1662.92
1668.33
1674.28
1681.38
1693.52
1702.98
1712.23
1720.23
1728.12
1736.42
1746.68
1754.68
1761.37
1767.65
1774.43
1781.12
1789.7
1794.37
1799.62
1804.12
1810.85
1816.2
1817.7
1815.77
1813.72
1810.3
1805.83
1800.78
1796.25
1790.75
1784.77
1779.18
1774.27
1769.65
1763.78
1758.07
1751.17
1743.35
1735.27
1726.83
1717.27
1706.7
1695.0
1683.42
1670.8
1657.45
1645.77
1634.07
1622.58
1612.32
1602.03
)

Gui, 1: Font, s12 q5 c666666
Gui, 1:Color, White
Gui, 1:Add, Picture, x5 y5 w505 h200 BackgroundTrans 0xE vPic
Gui, 1:Add, Text, x5 y210 w505 h25 Center, [improvisation] rotated BarChart = ColumnChart

pToken := Gdip_Startup()
pBitmap := BarChart(ChartData, 200, 505)
pRotatedBitmap := Gdip_RotateBitmap(pBitmap, -90) ; rotates bitmap for -90 degrees. Disposes of pBitmap.
SetBitmap2Pic(pRotatedBitmap,"Pic")
Gdip_DisposeImage(pRotatedBitmap)
Gdip_Shutdown(pToken)

Gui 1:Show, w515 h240, [improvisation] ColumnChart
return


;===Subroutines=========================================================================
GuiClose:
ExitApp


;===Functions===========================================================================
#Include %A_ScriptDir%\Gdip.ahk			; by Tic
#Include %A_ScriptDir%\BarChart.ahk		; by Learning one

SetBitmap2Pic(pBitmap,ControlID,GuiNum=1) {	; sets pBitmap to picture control (which must have 0xE option and should have BackgroundTrans option). By Learning one.
	GuiControlGet, hControl, %GuiNum%:hwnd, %ControlID%
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap), SetImage(hControl, hBitmap), DeleteObject(hBitmap)	
	GuiControl, %GuiNum%:MoveDraw, %ControlID%	; repaints the region of the GUI window occupied by the control
}

Gdip_RotateBitmap(pBitmap, Angle, Dispose=1) {	; returns rotated bitmap. By Learning one.
	Gdip_GetImageDimensions(pBitmap, Width, Height)
	Gdip_GetRotatedDimensions(Width, Height, Angle, RWidth, RHeight)
	Gdip_GetRotatedTranslation(Width, Height, Angle, xTranslation, yTranslation)
	
	pBitmap2 := Gdip_CreateBitmap(RWidth, RHeight)
	G2 := Gdip_GraphicsFromImage(pBitmap2), Gdip_SetSmoothingMode(G2, 4), Gdip_SetInterpolationMode(G2, 7)
	Gdip_TranslateWorldTransform(G2, xTranslation, yTranslation)
	Gdip_RotateWorldTransform(G2, Angle)
	Gdip_DrawImage(G2, pBitmap, 0, 0, Width, Height)
	
	Gdip_ResetWorldTransform(G2)
	Gdip_DeleteGraphics(G2)
	if Dispose
		Gdip_DisposeImage(pBitmap)
	return pBitmap2
}