classdef ColorX11Enum < int32 % & enumDA.EnumExtensions
%% EXAMPLES
%{

%}  
%% VERSIONING
%             Author: Andreas Justin
%           Copyright (C) 
%      Creation date: 2014-02-06
%             Matlab: 8.2.0.701 (R2013b)
%  Required Products: -
%
%% REVISIONS
% V1.0 | 2014-02-06 | Andreas Justin    | Ersterstellung
%
%
% See also http://en.wikipedia.org/wiki/Web_colors#X11_color_names
    enumeration
    % Pink colors
        Pink                 (hex2dec('FFC0CB'))
        LightPink            (hex2dec('FFB6C1'))
        HotPink              (hex2dec('FF69B4'))
        DeepPink             (hex2dec('FF1493'))
        PaleVioletRed        (hex2dec('DB7093'))
        MediumVioletRed      (hex2dec('C71585'))

    % Red colors
        LightSalmon          (hex2dec('FFA07A'))
        Salmon               (hex2dec('FA8072'))
        DarkSalmon           (hex2dec('E9967A'))
        LightCoral           (hex2dec('F08080'))
        IndianRed            (hex2dec('CD5C5C'))
        Crimson              (hex2dec('DC143C'))
        FireBrick            (hex2dec('B22222'))
        DarkRed              (hex2dec('8B0000'))
        Red                  (hex2dec('FF0000'))

    % Orange colors
        OrangeRed            (hex2dec('FF4500'))
        Tomato               (hex2dec('FF6347'))
        Coral                (hex2dec('FF7F50'))
        DarkOrange           (hex2dec('FF8C00'))
        Orange               (hex2dec('FFA500'))
        Gold                 (hex2dec('FFD700'))

    % Yellow colors
        Yellow               (hex2dec('FFFF00'))
        LightYellow          (hex2dec('FFFFE0'))
        LemonChiffon         (hex2dec('FFFACD'))
        LightGoldenrodYellow (hex2dec('FAFAD2'))
        PapayaWhip           (hex2dec('FFEFD5'))
        Moccasin             (hex2dec('FFE4B5'))
        PeachPuff            (hex2dec('FFDAB9'))
        PaleGoldenrod        (hex2dec('EEE8AA'))
        Khaki                (hex2dec('F0E68C'))
        DarkKhaki            (hex2dec('BDB76B'))

    % Brown colors
        Cornsilk             (hex2dec('FFF8DC'))
        BlanchedAlmond       (hex2dec('FFEBCD'))
        Bisque               (hex2dec('FFE4C4'))
        NavajoWhite          (hex2dec('FFDEAD'))
        Wheat                (hex2dec('F5DEB3'))
        BurlyWood            (hex2dec('DEB887'))
        Tan                  (hex2dec('D2B48C'))
        RosyBrown            (hex2dec('BC8F8F'))
        SandyBrown           (hex2dec('F4A460'))
        Goldenrod            (hex2dec('DAA520'))
        DarkGoldenrod        (hex2dec('B8860B'))
        Peru                 (hex2dec('CD853F'))
        Chocolate            (hex2dec('D2691E'))
        SaddleBrown          (hex2dec('8B4513'))
        Sienna               (hex2dec('A0522D'))
        Brown                (hex2dec('A52A2A'))
        Maroon               (hex2dec('800000'))

    % Green colors
        DarkOliveGreen       (hex2dec('556B2F'))
        Olive                (hex2dec('808000'))
        OliveDrab            (hex2dec('6B8E23'))
        YellowGreen          (hex2dec('9ACD32'))
        LimeGreen            (hex2dec('32CD32'))
        Lime                 (hex2dec('00FF00'))
        LawnGreen            (hex2dec('7CFC00'))
        Chartreuse           (hex2dec('7FFF00'))
        GreenYellow          (hex2dec('ADFF2F'))
        SpringGreen          (hex2dec('00FF7F'))
        MediumSpringGreen    (hex2dec('00FA9A'))
        LightGreen           (hex2dec('90EE90'))
        PaleGreen            (hex2dec('98FB98'))
        DarkSeaGreen         (hex2dec('8FBC8F'))
        MediumSeaGreen       (hex2dec('3CB371'))
        SeaGreen             (hex2dec('2E8B57'))
        ForestGreen          (hex2dec('228B22'))
        Green                (hex2dec('008000'))
        DarkGreen            (hex2dec('006400'))

    % Cyan colors
        MediumAquamarine     (hex2dec('66CDAA'))
        Aqua                 (hex2dec('00FFFF'))
        Cyan                 (hex2dec('00FFFF'))
        LightCyan            (hex2dec('E0FFFF'))
        PaleTurquoise        (hex2dec('AFEEEE'))
        Aquamarine           (hex2dec('7FFFD4'))
        Turquoise            (hex2dec('40E0D0'))
        MediumTurquoise      (hex2dec('48D1CC'))
        DarkTurquoise        (hex2dec('00CED1'))
        LightSeaGreen        (hex2dec('20B2AA'))
        CadetBlue            (hex2dec('5F9EA0'))
        DarkCyan             (hex2dec('008B8B'))
        Teal                 (hex2dec('008080'))

    % Blue colors
        LightSteelBlue       (hex2dec('B0C4DE'))
        PowderBlue           (hex2dec('B0E0E6'))
        LightBlue            (hex2dec('ADD8E6'))
        SkyBlue              (hex2dec('87CEEB'))
        LightSkyBlue         (hex2dec('87CEFA'))
        DeepSkyBlue          (hex2dec('00BFFF'))
        DodgerBlue           (hex2dec('1E90FF'))
        CornflowerBlue       (hex2dec('6495ED'))
        SteelBlue            (hex2dec('4682B4'))
        RoyalBlue            (hex2dec('4169E1'))
        Blue                 (hex2dec('0000FF'))
        MediumBlue           (hex2dec('0000CD'))
        DarkBlue             (hex2dec('00008B'))
        Navy                 (hex2dec('000080'))
        MidnightBlue         (hex2dec('191970'))

    % Purple colors
        Lavender             (hex2dec('E6E6FA'))
        Thistle              (hex2dec('D8BFD8'))
        Plum                 (hex2dec('DDA0DD'))
        Violet               (hex2dec('EE82EE'))
        Orchid               (hex2dec('DA70D6'))
        Fuchsia              (hex2dec('FF00FF'))
        Magenta              (hex2dec('FF00FF'))
        MediumOrchid         (hex2dec('BA55D3'))
        MediumPurple         (hex2dec('9370DB'))
        BlueViolet           (hex2dec('8A2BE2'))
        DarkViolet           (hex2dec('9400D3'))
        DarkOrchid           (hex2dec('9932CC'))
        DarkMagenta          (hex2dec('8B008B'))
        Purple               (hex2dec('800080'))
        Indigo               (hex2dec('4B0082'))
        DarkSlateBlue        (hex2dec('483D8B'))
        SlateBlue            (hex2dec('6A5ACD'))
        MediumSlateBlue      (hex2dec('7B68EE'))

    % White colors
        White                (hex2dec('FFFFFF'))
        Snow                 (hex2dec('FFFAFA'))
        Honeydew             (hex2dec('F0FFF0'))
        MintCream            (hex2dec('F5FFFA'))
        Azure                (hex2dec('F0FFFF'))
        AliceBlue            (hex2dec('F0F8FF'))
        GhostWhite           (hex2dec('F8F8FF'))
        WhiteSmoke           (hex2dec('F5F5F5'))
        Seashell             (hex2dec('FFF5EE'))
        Beige                (hex2dec('F5F5DC'))
        OldLace              (hex2dec('FDF5E6'))
        FloralWhite          (hex2dec('FFFAF0'))
        Ivory                (hex2dec('FFFFF0'))
        AntiqueWhite         (hex2dec('FAEBD7'))
        Linen                (hex2dec('FAF0E6'))
        LavenderBlush        (hex2dec('FFF0F5'))
        MistyRose            (hex2dec('FFE4E1'))

    % Gray/Black colors
        Gainsboro            (hex2dec('DCDCDC'))
        LightGray            (hex2dec('D3D3D3'))
        Silver               (hex2dec('C0C0C0'))
        DarkGray             (hex2dec('A9A9A9'))
        Gray                 (hex2dec('808080'))
        DimGray              (hex2dec('696969'))
        LightSlateGray       (hex2dec('778899'))
        SlateGray            (hex2dec('708090'))
        DarkSlateGray        (hex2dec('2F4F4F'))
        Black                (hex2dec('000000'))
    end
    
    methods 
        function color = toColor(obj)
            color = grafik.Color.valueOfHex(dec2hex(obj.uint32));
        end
    end
    methods (Static)
        %function enObj = valueOfHex(val)
        %    % konvertiert die Zahl val in eine Enumeration
        %    val = hex2dec(val);
        %    enObj = enumDA.getEnumOfNumber(mfilename('class'), val);
        %end
        %%% implemetation of abstract methods
        %function enObj = valueOfNumber(val)
        %    % konvertiert die Zahl val in eine Enumeration
        %    enObj = enumDA.getEnumOfNumber(mfilename('class'), val);
        %end
        %function enObj = valueOfText(text)
        %    % konvertiert die Zahl val in eine Enumeration
        %    enObj = enumDA.getEnumOfText(mfilename('class'), text);
        %end
        %function enObj = valueOf(valOrText)
        %    % konvertiert den Wert oder Text auf das entsprechende Enumeration Object
        %    enObj = enumDA.getEnum(mfilename('class'), valOrText);
        %end
    end
end

