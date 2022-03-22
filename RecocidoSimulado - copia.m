clear all
clc

syms x1 x2 x3 x4 z y;

funcionZ=30*x1+35*x2-2*x1^2-3*x2^2;
iteraciones = 20;
iteracion=1;
c = 0.5;
bandera=1;
%vector inicial
% resto=[5 6 0 0;
%     14 6 10 0;
%     11 12 5 0;
%     11 0 10 0];
resto = zeros (4, 4);
for i=1:4
    resto(i, 1)=i;
    resto(i, 2)=rand(1)*16;
    resto(i, 3)=rand(1)*16;
end
%Primera Solucion Aceptada
% a=12;%x1
% b=8;%x2
a=rand(1)*16;
b=rand(1)*16;
k=1;

n=1;
ra1=-6;
ra2=6;
%Penalizacion
q=15;
sigma=0.1;
temperatura=0;
%% Hallar la TemperaturaIncial
for i=1:4
    resto(i,4)=subs(funcionZ,{x1, x2}, {resto(i,1), resto(i,2)});
    temperatura=temperatura+resto(i,4);
end

promedio=temperatura/4;
fprintf('temperatura inicial : %8.5f', promedio);
%%Restricciones
ResTc1=x1^2+x2^2-250;
ResTc2=x1+x2-20;
ValueRest1=double(subs(ResTc1, {x1,x2}, {a,b}));
ValueRest2=double(subs(ResTc2, {x1,x2}, {a,b}));
%% Restriccion Penalizacion de la funcion Objetivo
%valor Objetivo en x1 y x2 inciial
Zob = double(subs(funcionZ, {x1,x2}, {a,b}))-q*(abs(ValueRest1)+abs(ValueRest2));
%Solucion Vecina

Soluciones_Aceptadas=zeros(iteraciones, 4);
Soluciones_Aceptadas(1,1)=a;
Soluciones_Aceptadas(1,2)=b;
Soluciones_Aceptadas(1,3)=Zob;
Soluciones_Aceptadas(1,4)=promedio;
%%Vecindad
%El bucle se genera desde aqui...
while true
    if bandera==1
        Vec = [Soluciones_Aceptadas(iteracion,1) Soluciones_Aceptadas(iteracion,1);
            Soluciones_Aceptadas(iteracion,2) Soluciones_Aceptadas(iteracion,2)];
        for i=1:2
            Vec(i,1)=Vec(i,1)+ra1;
            Vec(i,2)=Vec(i,2)+ra2;
        end
    end
    %Determinar u1 y u2
    %     u1 = 0.84;
    %     u2 = 0.66;
    while true
        u1=rand(1);
        u2=rand(1);

        %Hallar r1 y r2
        r1= Vec(1,1)+u1*(Vec(1,2)-Vec(1,1));
        r2= Vec(2,1)+u2*(Vec(2,2)-Vec(2,1));
        %if r1>=0 && r2>=0 && (r1+r2<=20) && ((r1^2)+(2*(r2^2)))<=250
        if r1>=0 && r2>=0 
            break
        end
    end

    %%Evaluamos la funcion Para la solucion vecina
    SolucionVecina=double(subs(funcionZ, {x1,x2}, {r1,r2}));

    if SolucionVecina>Soluciones_Aceptadas(iteracion,3)
        iteracion=iteracion+1;
        Soluciones_Aceptadas(iteracion,1)=r1;
        Soluciones_Aceptadas(iteracion,2)=r2;
        Soluciones_Aceptadas(iteracion,3)=SolucionVecina;
        Soluciones_Aceptadas(iteracion,4)=Soluciones_Aceptadas(iteracion-1,4)*c;
        bandera=1;
    else
        P=double(exp(-(SolucionVecina-Zob)/(k*SolucionVecina)));
        A=rand(1);
        if A<P
            Soluciones_Aceptadas(iteracion,1)=r1;
            Soluciones_Aceptadas(iteracion,2)=r2;
            Soluciones_Aceptadas(iteracion,3)=SolucionVecina;
            Soluciones_Aceptadas(iteracion,4)=Soluciones_Aceptadas(iteracion-1,4)*c;
            bandera=1;
        else
            bandera=0;
        end


    end
    sigma_problema=1;
    if iteracion>10
    %%calculo Sigma
    Fo=0;
    for i=iteracion-10:iteracion
        Fo=Fo+Soluciones_Aceptadas(i,3);
    end
    PromedioFo=Fo/10;
    sigma_problema=0;
    for i=iteracion-10:iteracion
        sigma_problema=  sigma_problema + ((Soluciones_Aceptadas(i,3)-PromedioFo)^2);
    end
    sigma_problema=sqrt(sigma_problema/10);
    end

    
    if iteracion-1==iteraciones || sigma_problema<sigma
        break
    end
   
end


fprintf('Se Realizaron : %d Iteraciones', iteracion-1);
fprintf('\nEl valor de x1 es: %8.12f\n', Soluciones_Aceptadas(i,1));
fprintf('\nEl valor de x2 es: %8.12f\n', Soluciones_Aceptadas(i,2));
fprintf('\nEl valor de la función es: %8.12f\n', Soluciones_Aceptadas(i,3));
fprintf('\nEl valor de la temperatura es: %8.12f\n', Soluciones_Aceptadas(i,4));
fprintf('\nEl valor de sigma es: %8.12f\n', sigma_problema);