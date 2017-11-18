classdef Color < handle
% daColorobject mit sammlungen verschiedener color eingabe arten mit einfacher konvertierung
%% EXAMPLES
%{

color = grafik.Color.colorPicker()

color = grafik.Color.valueOfRGB255(250,192,144)

color = grafik.Color.valueOfHex('a')
color = grafik.Color.valueOfHex('ab')
color = grafik.Color.valueOfHex('abc')
color = grafik.Color.valueOfHex('abacad')

color = grafik.Color.valueOfJava(java.awt.Color(1,1,1))
color = grafik.Color.valueOfJava(java.awt.Color(1,0.1,1))

color = grafik.Color.valueOfMatlab(1)
color = grafik.Color.valueOfMatlab([1,1,1])
color = grafik.Color.valueOfRGB255(100,200,75)

grafik.Color.valueOfRGB255(255)

color.toHex
color.toJava
color.toMatlabVector
color.toVB


%}  
%% VERSIONING
%             Author: Andreas Justin
%           Copyright (C)
%      Creation date: 2013-12-16
%             Matlab: 8.2.0.701 (R2013b)
%  Required Products: -
%
%% REVISIONS
% V1.0 | 2013-12-16 | Andreas Justin    | Ersterstellung
%
% See also 

%% --------------------------------------------------------------------------------------------
    properties(SetAccess = immutable)
        % the red color component in the range (0.0 - 1.0)
        r@double scalar
        % the green color component in the range (0.0 - 1.0)
        g@double scalar
        % the blue color component in the range (0.0 - 1.0)
        b@double scalar
    end
    properties (Dependent)
       color
    end
    
    methods
        function obj = Color(r,g,b)
            % Constructor
            if ~(isscalar(r) && (r >= 0.0) && (r <= 1.0)),  error('DAClass:wrongInput','the RED component must be a scalar value in the range 0.0 - 1.0! (is: %g)\n',r);    end
            if ~(isscalar(g) && (g >= 0.0) && (g <= 1.0)),  error('DAClass:wrongInput','the GREEN component must be a scalar value in the range 0.0 - 1.0! (is: %g)\n',g);    end
            if ~(isscalar(b) && (b >= 0.0) && (b <= 1.0)),  error('DAClass:wrongInput','the BLUE component must be a scalar value in the range 0.0 - 1.0! (is: %g)\n',b);    end
            obj.r = r;
            obj.g = g;
            obj.b = b;
        end
        function color = get.color(obj)
            color = [obj.r,obj.g,obj.b];
        end

    end
    methods
        function val = toRGB255(obj)
            val = round(obj.color*255);
        end
        function val = toHex(obj)
            val = dec2hex(obj.toRGB255,2);
            val = [val(1,:),val(2,:),val(3,:)];
        end
        function val = toMatlabVector(obj)
            val = obj.color;
        end
        function val = toVB(obj)
            val = sum(floor(obj.toRGB255) .* (256.^[0,1,2]));
        end
        function val = toJava(obj)
            val = java.awt.Color(obj.r, obj.g, obj.b);
        end
        function hsb = toHSB(obj)
            error('not Working yet')
            % an array of three elements containing the hue, saturation, and brightness (in that
            % order), of the color with the indicated red, green, and blue components 
            hsb = java.awt.Color.RGBtoHSB(obj.r, obj.g, obj.b, []);
        end
    end
    methods (Static)
        function obj = valueOfRGB255(r,g,b)
            % r,g,b values must be in the range 0 - 255
            if nargin < 2 || isempty(g) && isempty(b)
                if numel(r) > 1
                    obj = grafik.Color.valueOfMatlab(r./255);
                    return;
                else
                    g = r;
                    b = r;
                end
            end
            obj = grafik.Color(r/255, g/255, b/255);
        end
        function obj = valueOfHex(RGB)
            % 0 - 9 a-f A-F
            if ~isempty(regexp(RGB,'[g-zG-Z\-]','once'))
                error('daColor:invalidInput','hex can only be characters between 0-9 a-f A-F'); 
            end
            if mod(numel(RGB),7) < 3
                RGB = regexprep(RGB,'(.*)','${repmat($1,1,6/mod(numel($1),6))}');
            elseif numel(RGB) == 3
                % for example, code 609 is equivalent HEX code #660099.
                RGB = char(kron(RGB,[1,1]));
            elseif numel(RGB) == 6 % nvmd
            else
                error('daColor:invalidInput','invalid hex Color');
            end
            obj = grafik.Color.valueOfRGB255(hex2dec(RGB(1:2)), hex2dec(RGB(3:4)), hex2dec(RGB(5:6)));
        end
        function obj = valueOfMatlab(rgbVector)
            % 0 - 1
            if numel(rgbVector) == 1; rgbVector = repmat(rgbVector,1,3);    end
            obj = grafik.Color(rgbVector(1), rgbVector(2), rgbVector(3));
        end
        function obj = valueOfVB(RGB)
            % 0 - 16777215
            colorH = regexprep(dec2hex(RGB),'(.*)','${repmat(''0'',1,6-numel($1))}$1');
            if numel(colorH) > 6;   error('daColor:WrongInput','Zahl zu groﬂ'); end
            obj = grafik.Color.valueOfHex([colorH(5:6),colorH(3:4),colorH(1:2)]);
        end
        function obj = valueOfJava(jRGB)
            % 0 - 1
            obj = grafik.Color.valueOfRGB255(jRGB.getRed(), jRGB.getGreen(), jRGB.getBlue());
        end
        function obj = valueOfHSB(h,s,b)
            error('not Working yet')
            %{
                ï Hue is the actual color. It is measured in angular degrees counter-clockwise around the cone starting 
                    and ending at red = 0 or 360 (so yellow = 60, green = 120, etc.).
                ï Saturation is the purity of the color, measured in percent from the center of the cone (0) 
                    to the surface (100). At 0% saturation, hue is meaningless.
                ï Brightness is measured in percent from black (0) to white (100). 
                    At 0% brightness, both hue and saturation are meaningless.
            %}
            jRGB = java.awt.Color.getHSBColor(h,s,b);
            obj = grafik.Color.valueOfJava(jRGB);
        end
        function obj = colorPicker()
            color = uisetcolor;
            obj = grafik.Color.valueOfMatlab(color);
        end
        
        function color = valueOfPalette(key)
            import grafik.Color;
            keySet = {
                'redDark',      'redLight',...
                'orangeDark',   'orangeLight',...
                'yellowDark',   'yellowLight',...
                'greenDark',    'greenLight',...
                'blueDark',     'blueLight',...
                'violetDark',   'violetLight',...
                'greyDark',     'greyLight',...
                'black',        'white'
                };
            values = {
                Color.valueOfRGB255(156,  0,  6), Color.valueOfRGB255(255,199,206),...  red
                Color.valueOfRGB255(202, 82, 36), Color.valueOfRGB255(252,175, 62),...  orange
                Color.valueOfRGB255(156,101,  0), Color.valueOfRGB255(255,235,156),...  yellow
                Color.valueOfRGB255(  0, 97,  0), Color.valueOfRGB255(198,239,206),...  green
                Color.valueOfRGB255( 31, 73,125), Color.valueOfRGB255(219,229,241),...  blue
                Color.valueOfRGB255( 63, 49, 81), Color.valueOfRGB255(178,161,199),...  biolet
                Color.valueOfRGB255( 63, 63, 63), Color.valueOfRGB255(200,200,200),...  grey
                Color.valueOfRGB255(  0,  0,  0), Color.valueOfRGB255(255,255,255),...  black/white
                };
            colorPalette = containers.Map(keySet,values);
            
            if nargin < 1 || isempty(key)
                fprintf('\nPosible Values are: %s\n',strjoin(colorPalette.keys, ', '))
                return 
            end
            try
                color = colorPalette(key);
            catch err
                error('%s\n\nAllowed Values are: %s', err.getReport,strjoin(colorPalette.keys, ', ')) 
            end
        end
        function color = valueOfX11Palette(key)
            % http://en.wikipedia.org/wiki/Web_colors#X11_color_names
            if ischar(key)
                color = grafik.ColorX11Enum.(key).toColor;
            elseif isa(key,'grafik.ColorX11Enum')
                color = grafik.Color.valueOfHex(dec2hex(key.int32));
            end
        end
        
        function color = valueOf(key, varargin)
            if ~isempty(varargin);  key = [key,varargin{1},varargin{2}];    end
            if isa(key,'grafik.ColorX11Enum');  color = key.toColor;
            elseif isa(key,'grafik.Color');         color = key;
            elseif isnumeric(key) && numel(key) == 3 && all(key <= 1); 
                color = grafik.Color.valueOfMatlab(key);
            elseif isnumeric(key) && numel(key) == 3 && any(key > 1);  
                color = grafik.Color.valueOfRGB255(key);
            elseif isnumeric(key) && numel(key) == 1 && any(key > 1);  
                color = grafik.Color.valueOfVB(key);
            elseif ischar(key) 
                color = grafik.Color.valueOfHex(key);
            else grafik.Color.throwRGB_err(key)
            end
        end
    end
    
    methods (Static = true, Access = private)
        function throwRGB_err(key)
            switch class(key)
                case 'char'
                    error('FormatCondition:WrongInput',...
                        'key %s is invalid; key should be an 1x1, 1x2, 1x3, 1x6 [0-9a-fA-F] char vector',key);
                case 'double'
                    error('FormatCondition:WrongInput',...
                        'key %d is invalid; key should be an 1x1 [1-16777215] scalar or an 1x3 [0-1, 0-255] double vector',key);
                case 'cell'
                    error('FormatCondition:WrongInput','key as cell is invalid; key should be a numeric or a char');
                otherwise
                    error('FormatCondition:WrongInput','key is not valid; key should be a numeric or a char');
            end
        end
    end
end

