function [img, imgBin, imgEdge, imgProps, THRESH] = lecturaIMG_IMDS(IMDS)
img = read(IMDS);

    % Preprocesamiento y obtención de parámetros
    try
        img = rgb2gray(img);
    catch exception
        if strcmp(exception.identifier, 'MATLAB:images:rgb2gray:invalidSizeForColormap') 
        % imagen en gris / bin
        fprintf(strcat("Imagen tipo: "), class(img), " no necesaria conversión a gris \n");
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
    imgProps = regionprops(imgBin, "all");
end