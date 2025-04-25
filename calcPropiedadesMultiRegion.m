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
function [area, perimetro, per2_area, centroidePonderado, firma, std_firma, bboxes_mat, num_regions] = calcPropiedadesMultiRegion(img, imgBin, imgEdge, imgProps)
num_regions = numel({imgProps.Area});

bboxes = {imgProps.BoundingBox};
areas = {imgProps.Area};
centroides = {imgProps.Centroid};
perimetros = {imgProps.Perimeter};

% Elimina propiedades redundanete
if num_regions > 1
[areas, perimetros, centroides, bboxes, num_regions] = depuraProps(imgBin, imgProps);
end


% Conversión de tipo
[areas_mat, perimetros_mat, centroides_mat, bboxes_mat] =...
    impropsAMatriz(areas, perimetros, centroides, bboxes); 

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