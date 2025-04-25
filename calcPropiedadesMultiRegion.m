% Cálcula las propiedades para aquellas imagenes con más de una región
% detectada en la imagen
% [area, perimetro, per2_area, centroidePonderado, firma, std_firma, bboxes_mat] = calcPropiedadesMultiRegion(img, imgBin, imgEdge, imgProps)
%{
OUTPUTS----------------------------------------------------
area : area de la pieza, suma del area de todas las regiones.
perimetro: suma de todos los perimetros de las regiones.
per2_area: perimetro^2 / area.
centroidePonderado = centroide global de la imagen, teniendo en cuenta los
centroides de cada región y sus respectivas áreas.
firma: firma de la imagen.
std_firma: desviación estándar de la imagen (cuánto más pequeña más
parecida a un circul).
bboxes_mat: Matriz de dimensiones NUM_REGIONES x 4, contenienedo todas las
bounding boxes en formato [x, y, width, height].

INPUTS----------------------------------------------------
img: imagen
imgBin: imagen binaria.
imgEdge: Imagen de bordes.
imgProps: estructura de propiedades de la imagen obtenida por regionProps.
%}
function [area, perimetro, per2_area, centroidePonderado, firma, std_firma, bboxes_mat] = calcPropiedadesMultiRegion(img, imgBin, imgEdge, imgProps)
    num_regions = numel({imgProps.Area});

    bboxes = {imgProps.BoundingBox};
    areas = {imgProps.Area};
    centroides = {imgProps.Centroid};
    perimetros = {imgProps.Perimeter};

    % Elimina propiedades redundanetes ( no pertenecne a la figura sino a
    % la imagen completa) 
    try 
  [areas, perimetros, centroides, bboxes] = depuraProps(imgBin, imgProps);
    catch exception
        exception	
    end

    % Conversión a un tipo fácil de trabajar
    areas_mat = cell2mat(areas);
    num_regions = length(areas_mat);
    perimetros_mat = cell2mat(perimetros);

    centroides_mat  = zeros(num_regions, 2);
    bboxes_mat  = zeros(num_regions, 4);
    for region =  num_regions:-1:1
        centroides_mat(region,:) = cell2mat(centroides(region));
        bboxes_mat(region, :) = cell2mat(bboxes(region));
    end

    for region = 1 : num_regions
        if areas_mat(region) < 0.4*max(areas_mat(region))
            bboxes(region) = [];
            areas(region) = [];
            centroides(region) = [];
            perimetros(region) = [];
            imgBin(seccion_area) = zeros(size(seccion_area));
        end
    end

    % Cálculo de las propiedades
    area = sum(areas_mat, "all");
    perimetro = sum(perimetros_mat, "all");
    per2_area = perimetro^2/area;

    XcentroidePonderado = (areas_mat * centroides_mat(:,1))/area;
    YcentroidePonderado = (areas_mat * centroides_mat(:,2))/area;
    centroidePonderado = [XcentroidePonderado, YcentroidePonderado];
    firma = calculaFirma(imgBin,centroidePonderado);
    std_firma = std(firma);

    for region = 1 : num_regions
        x = bboxes_mat(region, 1);
        y = bboxes_mat(region, 2);
        w = bboxes_mat(region, 3);
        h = bboxes_mat(region, 4);
    end

end