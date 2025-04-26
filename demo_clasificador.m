clc, clear, close all, load clasificador.mat
global recursiveRecallCounter
recursiveRecallCounter = 0;
%% IMPORTACIÓN

% defino dataset y creo el data store
% Nota: Funciona en local, cambia el PATH del DATASET al de tu máquina:
DATASET_PATH = 'C:\Users\Antonio\Documents\MATLAB\GITI\PERCEPCION\PROYECTO\vehicles_test_augmented';


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
    [img, imgBin, imgEdge, THRESH] = lecturaIMG_IMDS(IMDS, IMG_SIZE);

    % Cálculo de las propiedades
    [area, perimetro, bboxes_mat, per2_area, centroidePonderado, firma, std_firma, num_regions] =...
        calcPropiedades(img, imgBin, imgEdge);

    % cálculo del centroide relativo
    centroideRelativo = centroidePonderado / area;

    % Cálculo del vector de características
    caracteristicas = [area, perimetro, per2_area, centroideRelativo, std_firma, num_regions];
    X = [X; caracteristicas];
    clase = IMDS.Labels(iter);
    Y = [Y; clase];

    iter = iter +1 ;
end

%% Train & Predict

%{
 caracteristicas = [area, perimetro, per2_area, centroideRelativo, std_firma, num_regions, num_regions_NotBin];
X = [X; caracteristicas];
clase = IMDS.Labels(iter);
Y = [Y; clase];
%}

Y_pred = clasificador.predict(X);
Y = double(Y);
Y_pred = double(Y_pred);

%% Plot
representa(Y, Y_pred, NUM_LABELS)