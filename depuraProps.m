% Elimina aquellas propiedades que pertenecen a la "region" de la imagen
% completa, es decir, aquellas asociadas a una bounding box de igual
% dimensión que la imagen.
% También elimina aquellas propiedades asociadas a regiones menores que
% cierto porporción (0.6 por defecto) de la mayor región.
function [areas, perimetros, centroides, bboxes, num_regions] = depuraProps(imgBin, imgProps, COEF)
if nargin < 3; COEF = 0.6; end

num_regions = numel({imgProps.Area});
NUM_REGIONS_1 = num_regions;

bboxes = {imgProps.BoundingBox};
areas = {imgProps.Area};
centroides = {imgProps.Centroid};
perimetros = {imgProps.Perimeter};

% Elimina props asociadas a regiones de tamaño igual que la imagen
for region = num_regions:-1:1
    bbox_region = cell2mat(bboxes(region));
    x = bbox_region(1);
    y = bbox_region(2);
    w = bbox_region(3);
    h = bbox_region(4);
    seccion_area = [x:(x)+w, y:(y+h)];

    if all(bbox_region(3:4) == size(imgBin))
        bboxes(region) = [];
        areas(region) = [];
        centroides(region) = [];
        perimetros(region) = [];
    end
end


num_regions = numel({areas});
while num_regions >= 2
    num_regions = numel({areas});
    for region = num_regions : -1 : 1
        [minArea, minIndx] = min(areas(region));
        [maxArea, maxIndx] = max(areas(region));
        if minArea <= COEF *maxArea
            bboxes(minIndx) = [];
            areas(minIndx) = [];
            centroides(minIndx) = [];
            perimetros(minIndx) = [];
            num_regions = numel({areas});
        elseif num_regions == 2 && minArea > COEF *maxArea
            break
        end
    end
    if num_regions == 2 && minArea > COEF *maxArea
        break
    end

    num_regions = numel({areas});
end
delRegions = NUM_REGIONS_1 - num_regions;
fprintf("depuraProps: %d / %d regiones eliminadas \n", delRegions, NUM_REGIONS_1)

%---%
end