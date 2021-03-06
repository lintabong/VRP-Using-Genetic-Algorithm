clear cd;
clc;
 
%deklarasi variable
data = 'data.xlsx';
K = 4; %penentuan jumlah cluster
n = 50; %jumlah  data
frame = 0.05;
vc = 150; %kapasitas kendaraan

%baca data dari excel

waktu = xlsread(data,2,'C4:AZ53');
Cwaktu = waktu;

for i = 1:size(nn_rute_usulan,1)
    a = 1;
    for o = 1:size(nn_rute_usulan,2)
        if nn_rute_usulan(i,o) == 0
            
        else
           
           route(i).suggest(o) = nn_rute_usulan(i,o);
           a = a + 1;
        end
    end
end

for i = 1:size(route,2)
    cd(i).routeN(1).id = 1;
    cd(i).routeN(1).ran = 0.001;
    cd(i).routeN(1).sug = 1;
    for a = 2:size(route(i).suggest,2)
        cd(i).routeN(a).id = a + 1;
        cd(i).routeN(a).ran = rand(1);
        cd(i).routeN(a).sug = route(i).suggest(a);
    end
    cd(i).routeN(a).id = a + 1;
    cd(i).routeN(a).ran = 0.999;
    cd(i).routeN(a).sug = 1; 
end


%MULAI ALGORITMA GENETIKA
for i = 1:size(route,2)
    %start parrent
    for o = 1:200
        waktuP = 0;
        waktuTot = 0;
        cd(i).parr(o).routeN(1).ran = 0.001;
        cd(i).parr(o).routeN(1).sug = 1;
        for a = 1:size(cd(i).routeN,2)-2
            cd(i).parr(o).routeN(a+1).ran = rand(1);
            cd(i).parr(o).routeN(a+1).sug = cd(i).routeN(a+1).sug;
        end
        cd(i).parr(o).routeN(size(cd(i).routeN,2)).ran = 0.999;
        cd(i).parr(o).routeN(size(cd(i).routeN,2)).sug = 1;
        
        [~,index] = sortrows([cd(i).parr(o).routeN.ran].');
        cd(i).parr(o).routeN = cd(i).parr(o).routeN(index);
        clear index
        
        %parr time
        for a = 2:size(cd(i).parr(o).routeN,2)
            t1 = cd(i).parr(o).routeN(a).sug;
            t2 = cd(i).parr(o).routeN(a-1).sug;
            waktuP = Cwaktu(t1,t2);
            waktuTot = waktuTot + waktuP;
        end
        cd(i).parr(o).waktu = waktuTot;
    end
    [~,index] = sortrows([cd(i).parr.waktu].');
    cd(i).parr = cd(i).parr(index);
    clear index
    
    %start crossover
    for o = 1:10
        if size(cd(i).routeN,2) <= 6
            break
        end
        for a = 1:size(cd(i).routeN, 2) + 2
            if a <= size(cd(i).routeN, 2)
                cd(i).cross(o).child(a).par1 = cd(i).parr(o).routeN(a).sug;
                cd(i).cross(o).child(a).par2 = cd(i).parr(o+10).routeN(a).sug;
                cd(i).cross(o).child(a).sug = cd(i).cross(o).child(a).par1;
            else
                cd(i).cross(o).child(a).par1 = 0;
                cd(i).cross(o).child(a).par2 = 0;
                cd(i).cross(o).child(a).sug = 0;
            end
        end
        
        cr1 = cd(i).cross(o).child(2).par2;
        cr2 = cd(i).cross(o).child(3).par2;
        
        for a = 1:size(cd(i).routeN, 2)
            if cd(i).cross(o).child(a).sug == cr1
                cd(i).cross(o).child(a).sug = [];
            elseif cd(i).cross(1).child(a).sug == cr2
                cd(i).cross(o).child(a).sug = [];
            end
        end
        
        for a = 1:size(cd(i).cross(o).child, 2)
            cd(i).cross(o).child(a).sugN = 0;
        end
        b = 1;
        for a = 1:size(cd(i).cross(o).child, 2) - 2
            if isempty(cd(i).cross(o).child(a).sug) == 1
                b = b + 1;
            elseif isempty(cd(i).cross(o).child(a).sug) == 1 && isempty(cd(i).cross(o).child(a+1).sug) == 1
                b = b + 2;
            end
            cd(i).cross(o).child(a).sugN = cd(i).cross(o).child(b).sug;
            b = b + 1;
        end
        cd(i).cross(o).child(size(cd(i).cross(o).child, 2)-4).sugN = cr1;
        cd(i).cross(o).child(size(cd(i).cross(o).child, 2)-3).sugN = cr2;
        cd(i).cross(o).child(size(cd(i).cross(o).child, 2)-2).sugN = 1;
        
        for a = 1:size(cd(i).cross(o).child, 2)
            if isempty(cd(i).cross(o).child(a).sugN)
                cd(i).cross(o).child(a).sugN = cd(i).cross(o).child(a+2).sug;
            end
        end
        
        %cros time
        for a = 2:size(cd(i).cross(o).child,2) - 2
            t1 = cd(i).cross(o).child(a).sugN;
            t2 = cd(i).cross(o).child(a-1).sugN;
            waktuP = Cwaktu(t1,t2);
            waktuTot = waktuTot + waktuP;
        end
        cd(i).cross(o).waktu = waktuTot;
    end
    
    %start mutation
    for o = 1:10
        if size(cd(i).routeN,2) <= 4
            break
        end
        for a = 1:size(cd(i).routeN, 2)
            cd(i).mut(o).routeN(a).sug = cd(i).parr(o).routeN(a).sug;
        end
        mu1 = cd(i).mut(o).routeN(2).sug;
        mu2 = cd(i).mut(o).routeN(3).sug;
        cd(i).mut(o).routeN(3).sug = mu1;
        cd(i).mut(o).routeN(2).sug = mu2;
        
        %mutt time
        for a = 2:size(cd(i).mut(o).routeN,2)
            t1 = cd(i).mut(o).routeN(a).sug;
            t2 = cd(i).mut(o).routeN(a-1).sug;
            waktuP = Cwaktu(t1,t2);
            waktuTot = waktuTot + waktuP;
        end
        cd(i).mut(o).waktu = waktuTot;
    end
end






