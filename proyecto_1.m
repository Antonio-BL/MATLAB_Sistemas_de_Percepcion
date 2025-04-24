clc, clear

%% IMPORTACIÓN

% defino dataset y creo el data store
% Nota: Funciona en local, cambia el PATH del DATASET al de tu máquina:
DATASET_PATH = 'C:\Users\Antonio\Documents\MATLAB\GITI\PERCEPCION\PROYECTO\train';

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
    THRESH = graythresh(img)*1.05;
    imgBin = ~imbinarize(img, THRESH);
    imgEdge = filter2(L, imgBin);
    imgProps = regionprops(imgBin);
    figure, imshow(imgBin)

    [histCounts, ~] = imhist(img);
    perimetro = sum(imgEdge, "all");
    area = imgProps.Area;
    centroide = calculaCentroide(imgBin);
    per2_area = perimetro^2 / area;

    % distribución de masa


    caracteristicas = [perimetro, area, per2_area];
    X = [X; caracteristicas];
    clase = IMDS.Labels(iter);
    Y = [Y; clase];

    iter = iter +1 ;
end

%% Train & Predict

clasificador = fitcdiscr(X,Y);
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