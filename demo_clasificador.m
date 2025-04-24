clc, clear, close all, load clasificador 
%% Importación del DATASET de validación
DATASET_PATH = 'C:\Users\Antonio\Documents\MATLAB\GITI\PERCEPCION\PROYECTO\valid';

% Obtención del dataset, creación del Image Dataset Store
IMDS = imageDatastore(DATASET_PATH, "IncludeSubfolders",true, ...
    "LabelSource","foldernames");

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
    img = uint8(img);

    % Obtencion propiedades
    imgBin = ~imbinarize(img);
    imgEdge = filter2(L, imgBin);
    imgProps = regionprops(imgBin);
    
    % Características clásicas
    perimetro = sum(imgEdge, "all"); 
    area = imgProps.Area; 
    per2_area = perimetro^2 / area; 
    centroide = imgProps.Centroid; 
    [histCounts, ~] = imhist(img); 

    % Características específicas
    [relatCentroide, distPeso] = ...
        calculaCaracteristicas(imgBin, imgEdge);
    
    % Construcción del regresor 
    caracteristicas = [per2_area, relatCentroide, distPeso];
    X = [X; caracteristicas];

    % Construcción de la variable dependiente (class label) 
    clase = IMDS.Labels(iter);
    Y = [Y; clase];

    % troubleshooting
    iter = iter +1 ;
end

%% Predict

Y_pred = clasificador.predict(X);

Y = double(Y);
Y_pred = double(Y_pred);

%% Representación

hold on
bar(1, nnz(double(Y_pred)==1),0.4 ,"stacked", "DisplayName", "Predicted")
bar(1.4, nnz(double(Y)==1),0.4, "stacked", "DisplayName", "Real")

bar(2, nnz(double(Y_pred)==2),0.4, "stacked")
bar(2.4, nnz(double(Y)==2),0.4, "stacked")

bar(3, nnz(double(Y_pred)==3),0.4,  "stacked")
bar(3.4, nnz(double(Y)==3),0.4, "stacked")
hold off
title("Resultados eval-set")
colororder(["r",'g', 'r', 'g', 'r', 'g'])
xticks([1, 2, 3])
xlabel("Clase predicha")
ylabel("Número de predicciones")
legend("Predicho", "Real")
