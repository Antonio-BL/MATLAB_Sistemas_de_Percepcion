clc, clear, close all
global recursiveRecallCounter imgCounter
recursiveRecallCounter = 0;
imgCounter = 0;
%% IMPORTACIÓN

% defino dataset y creo el data store
% Nota: Funciona en local, cambia el PATH del DATASET al de tu máquina:
DATASET_PATH = 'C:\Users\Antonio\Documents\MATLAB\GITI\PERCEPCION\PROYECTO\numbers_train';
DIR = dir(DATASET_PATH);
NUM_LABELS = nnz(~ismember({DIR.name},{'.','..'})&[DIR.isdir]);
LABELS = ({DIR.name});
% Posibilidad de directorios ocultos
for ii = 1 : NUM_LABELS; if LABELS{ii} == '.' || LABELS{ii} == ".."; LABELS(ii) = []; end
end
LABELS = ({DIR.name});

% Obtención del dataset, creación del Image Dataset Store
IMDS = imageDatastore(DATASET_PATH, "IncludeSubfolders",true, ...
    "LabelSource","foldernames");



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
    imgCounter = imgCounter + 1;
    % Lectura de imagen
    [img, imgBin, imgEdge,THRESH] = lecturaIMG_IMDS(IMDS, IMG_SIZE);
    imgsBin(:, :,iter) = imgBin; 
    % Cálculo de las propiedades
    [area, perimetro, bboxes_mat, per2_area, centroidePonderado, firma, std_firma, num_regions] =...
        calcPropiedades(img, imgBin, imgEdge);

    % cálculo del centroide relativo
    centroideRelativo = centroidePonderado / area;

    % Cálculo del vector de características
    caracteristicas = [ per2_area, centroideRelativo, std_firma, num_regions];
    X = [X; caracteristicas];
    clase = IMDS.Labels(iter);
    Y = [Y; clase];

    iter = iter +1 ;
end

%% Train & Predict

clasificador = fitcdiscr(X,Y);
Y_pred = clasificador.predict(X);
save clasificador.mat clasificador
Y = double(Y);
Y_pred = double(Y_pred);

for img = 1 : 200: imgCounter
    textos = {strcat("per2Area: ", num2str(X(img, 1))), ...
        strcat("std firma: ", num2str(X(img, 3))), ...
        strcat("num regiones: ", num2str(X(img, 4))), };

    % Número de textos
    n = numel(textos);

    % Crear la figura
    figure;
    hold on;

    % Mostrar la imagen
    imshow(imgsBin(:,:,img), 'InitialMagnification', 'fit');

    % Obtener límites actuales del eje
    ax = gca;
    xlim = ax.XLim;
    ylim = ax.YLim;

    % Calcular la posición del texto al lado derecho de la imagen
    % Dejamos un pequeño margen
    x_text = xlim(2) + 1;
    y_step = (ylim(2) - ylim(1)) / (n + 1);

    % Dibujar los textos verticalmente
    for i = 1:n
        y_text = ylim(2) - i * y_step;
        text(x_text, y_text, textos{i}, 'FontSize', 12, 'Color', 'k', ...
            'HorizontalAlignment', 'left');
    end

    % Ajustar los límites del eje para que quepa el texto
    ax.XLim = [xlim(1), x_text + 150]; % Ampliamos el eje x para que quepa el texto

    title(strcat('Número detectado: ',string(Y_pred(img)-1)));
end

%% Plot
clc
representa(Y, Y_pred, NUM_LABELS)

% scatter_Caract(X, Y, Y_pred)