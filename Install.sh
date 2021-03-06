echo "update script paths"
perl -p -i -e "s/RDIR=.*\n/RDIR=$( echo $(pwd)| perl -p -i -e "s/\//\\\\\//g")\n/g" scripts/RunRUFUS.1000G.withDupRemoce.sh
perl -p -i -e "s/RDIR=.*\n/RDIR=$( echo $(pwd)| perl -p -i -e "s/\//\\\\\//g")\n/g"  scripts/OverlapBashMultiThread.sh
perl -p -i -e "s/RDIR=.*\n/RDIR=$( echo $(pwd)| perl -p -i -e "s/\//\\\\\//g")\n/g"  scripts/RunJellyForRUFUS
perl -p -i -e "s/RDIR=.*\n/RDIR=$( echo $(pwd)| perl -p -i -e "s/\//\\\\\//g")\n/g"  scripts/HumanDedup.grenrator.tenplate



RUFUS_DIR=$(pwd)

echo "bulding rufus executables"
g++ src/AnnotateOverlap.cpp -o bin/AnnotateOverlap -std=gnu++0x -O3
g++ src/ConvertFASTqD.to.FASTQ.cpp -o bin/ConvertFASTqD.to.FASTQ -O3
g++ src/ModelDist.cpp -o bin/ModelDist -fopenmp 
g++ src/Overlap.cpp -o bin/Overlap -std=gnu++0x -fopenmp -O3
g++ src/OverlapRegion.cpp -o bin/OverlapRegion -std=gnu++0x -fopenmp -O3
g++ src/ReplaceQwithDinFASTQD.cpp -o bin/ReplaceQwithDinFASTQD  -O3
g++ ./src/RUFUS.Filter.cpp -o ./bin/RUFUS.Filter -std=gnu++0x -fopenmp -O3
g++ src/RUFUS.Build.cpp -o bin/RUFUS.Build -fopenmp -O3
g++ ./src/RUFUS.interpret.cpp ./src/include/* -o ./bin/RUFUS.interpret -std=gnu++0x -O3
g++ ./src/RUFUS.1kg.filter.cpp -o ./bin/RUFUS.1kg.filter -std=gnu++0x -fopenmp -O3

echo "bulding external programs"
cd src/externals/

if [ -e ./jellyfish-2.2.5/bin/jellyfish ]
then
        echo "jellyfish already installed: skipping"
else

        tar -xvf jellyfish-2.2.5.tar.gz
        cd jellyfish-2.2.5
        mkdir bin
        ./configure --prefix=$RUFUS_DIR/bin/jellyfish
        make
        make install
        cd ..
fi

cd $RUFUS_DIR/bin/
if [ -e ./gkno_launcher/gkno ]
then
        echo "know already built: skipping"
else
        git clone https://github.com/gkno/gkno_launcher.git
        cd gkno_launcher/
        ./gkno build
        cd ..
fi

if [ -e ./gkno_launcher/resources/homo_sapiens/build_37_version_3/human_reference_v37_decoys.fa ]
then
        echo "human reference paramaters set already downloaded: skipping"
else
        cd gkno_launcher
        ./gkno add-resource human
        ./gkno bwa-index -r ./resources/homo_sapiens/build_37_version_3/human_reference_v37_decoys.fa -x ./resources/homo_sapiens/build_37_version_3/human_reference_v37_decoys
        cd ..
fi

cd ../
