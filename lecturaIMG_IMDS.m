function [img, imgBin, imgEdge,  THRESH] = lecturaIMG_IMDS(IMDS, IMG_SIZE)
img = read(IMDS);
persistent L
L = [0, -1, 0;
    -1,  4, -1;
    0,  -1,  0] * 0.25;
% Preprocesamiento y obtención de parámetros
try
    img = rgb2gray(img);
catch exception
    if strcmp(exception.identifier, 'MATLAB:images:rgb2gray:invalidSizeForColormap')
        % imagen en gris / bin
        % fprintf("Imagen tipo: gris / bin no necesaria conversión a gris \n");
    else
        warning("Error en conversión de imagen no identificado");
    end
end
img = imresize(img, IMG_SIZE);

% Filtrado
img = medfilt2(img);
img = filter2(1/9*ones(3), img);
img = imopen(img, strel("rectangle", [3,3]));
img = imclose(img, strel("rectangle", [3 3]));
img = uint8(img);

% Obtencion propiedades
THRESH = graythresh(img);
imgBin = imbinarize(img, THRESH);
imgEdge = filter2(L, imgBin);
end