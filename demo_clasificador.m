clc, clear
load clasificador.mat
%% IMPORTACIÓN

% defino dataset y creo el data store
% Nota: Funciona en local, cambia el PATH del DATASET al de tu máquina:
DATASET_PATH = 'C:\Users\Antonio\Documents\MATLAB\GITI\PERCEPCION\PROYECTO\test';

% Obtención del dataset, creación del Image Dataset Store
IMDS = imageDatastore(DATASET_PATH, "IncludeSubfolders",true, ...
    "LabelSource","foldernames");

% ========================================= %
%         DESCRIPCIÓN DEL DATASET           %
% ========================================= %
%
% DEFINICIÓN INICIAL: CARACTERÍSTICAS: 3
% X = vector de características a definir:
%     histograma, distribución de pixeles
%     suma de píxeles binarizados
%     relación perímetro^2 / Área
% Y = labels.
%     0 : martillo
%     1 : LLave inglesa (ajustable o no)
%     2 : Wrench (tipo de llave inglesa)


%% OBTENCIÓN DE LOS VECTORES DE CARACTERÍSTICAS
iter = 1;
X = [];
Y = [];
MAX_ITER = 1e4;
IMG_SIZE = [400 400];
L = [0, -1, 0;
    -1,  4, -1;
    0,  -1,  0] * 0.25;

while hasdata(IMDS) && iter <= MAX_ITER

    % Lectura de imagen
    img = read(IMDS);

    % Preprocesamiento y obtención de parámetros
    img = rgb2gray(img);
    img = imresize(img, IMG_SIZE);

    % Filtrado
    img = medfilt2(img);
    img = filter2(1/9*ones(3), img);
    img = imopen(img, strel("rectangle", [3,3]));
    img = imclose(img, strel("rectangle", [3 3]));

    img = uint8(img);

    % Obtencion propiedades
    THRESH = graythresh(img)*1.10;
    imgBin = ~imbinarize(img, THRESH);
    imgEdge = filter2(L, imgBin);
    imgProps = regionprops(imgBin, "all");

    % Ddebido a la mala binarización de Otsu puede reconocer múltiples
    % regiones
    num_regions = numel({imgProps.Area});
    
    % múltiples regiones -----------------------------------------------
    % propiedades de cada región
    if num_regions >1
        bboxes = {imgProps.BoundingBox};
        areas = {imgProps.Area};
        centroides = {imgProps.Centroid};
        perimetros = {imgProps.Perimeter};
        
        bbox_region = zeros([1,4]);
        % recorrer hacia atrás para evitar problemas de apuntar a un índice
        % que no existe (longitud del cell variable)
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

            % probablemente sea ruido
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
        area = sum(areas_mat, "all"); 
        perimetro = sum(perimetros_mat, "all");
        per2_area = perimetro^2/area; 

        XcentroidePonderado = (areas_mat * centroides_mat(:,1))/area;
        YcentroidePonderado = (areas_mat * centroides_mat(:,2))/area;
        centroidePonderado = [XcentroidePonderado, YcentroidePonderado]; 
        
        figure
        imshow(imgBin); hold on
        for region = 1 : num_regions
            x = bboxes_mat(region, 1);
            y = bboxes_mat(region, 2);
            w = bboxes_mat(region, 3);
            h = bboxes_mat(region, 4);

            rectangle("Position",[x, y, w, h], "EdgeColor",'g')


        end
        hold off
    else    % solo una region -------------------------------------------------

    % figure, imshow(imgBin)

    [histCounts, ~] = imhist(img);

    perimetro = sum(imgEdge, "all");
    area = sum(imgBin,"all");
    centroidePonderado = calculaCentroide(imgBin);
    per2_area = perimetro^2 / area;
    
    end
    % Montaje del vector de características
    
    centroideRelativo = centroidePonderado / area;
    caracteristicas = [per2_area, centroideRelativo];
    X = [X; caracteristicas];
    clase = IMDS.Labels(iter);
    Y = [Y; clase];

    iter = iter +1 ;
end

%% Train & Predict

Y_pred = clasificador.predict(X);

Y = double(Y);
Y_pred = double(Y_pred);

%% Plot
figure
hold on
bar(1, nnz(double(Y_pred)==1),0.4 ,"stacked", "DisplayName", "Predicted")
bar(1.4, nnz(double(Y)==1),0.4, "stacked", "DisplayName", "Real")

bar(2, nnz(double(Y_pred)==2),0.4, "stacked")
bar(2.4, nnz(double(Y)==2),0.4, "stacked")

bar(3, nnz(double(Y_pred)==3),0.4,  "stacked")
bar(3.4, nnz(double(Y)==3),0.4, "stacked")
hold off
title("Resultados")
colororder(["r",'g', 'r', 'g', 'r', 'g'])
xticks([1, 2, 3])
xlabel("Clase predicha")
ylabel("Número de predicciones")
legend("Predicho", "Real")