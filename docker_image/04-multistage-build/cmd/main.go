package main

import (
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"github.com/spf13/cobra"
)

var (
	inputDir    string
	outputDir   string
	inputFile   string
	outputFile  string
	format      string
	quality     string
	workers     int
	verbose     bool
	watchMode   bool
	autoConvert bool
)

func main() {
	var rootCmd = &cobra.Command{
		Use:   "video-converter",
		Short: "Rota42 Video Converter - Converte vídeos usando FFmpeg",
		Long: `Um conversor de vídeos eficiente desenvolvido em Go para a Rota42.
Suporta conversão em lote, monitoramento de diretórios e múltiplos formatos.`,
		Run: func(cmd *cobra.Command, args []string) {
			if watchMode {
				runWatchMode()
			} else {
				runConversion()
			}
		},
	}

	// Definir flags
	rootCmd.PersistentFlags().StringVar(&inputDir, "input-dir", "/app/input", "Diretório de vídeos de entrada")
	rootCmd.PersistentFlags().StringVar(&outputDir, "output-dir", "/app/output", "Diretório de vídeos convertidos")
	rootCmd.PersistentFlags().StringVar(&inputFile, "input-file", "", "Arquivo específico para converter")
	rootCmd.PersistentFlags().StringVar(&outputFile, "output-file", "", "Arquivo de saída específico")
	rootCmd.PersistentFlags().StringVar(&format, "format", "mp4", "Formato de saída (mp4, avi, mkv, webm)")
	rootCmd.PersistentFlags().StringVar(&quality, "quality", "medium", "Qualidade do vídeo (low, medium, high)")
	rootCmd.PersistentFlags().IntVar(&workers, "workers", 2, "Número de workers paralelos")
	rootCmd.PersistentFlags().BoolVar(&verbose, "verbose", false, "Modo verbose")
	rootCmd.PersistentFlags().BoolVar(&watchMode, "watch", false, "Modo de monitoramento de diretório")
	rootCmd.PersistentFlags().BoolVar(&autoConvert, "auto-convert", false, "Conversão automática de novos arquivos")

	// Comando de health check
	var healthCmd = &cobra.Command{
		Use:   "health",
		Short: "Verifica se a aplicação está funcionando",
		Run: func(cmd *cobra.Command, args []string) {
			if checkFFmpeg() {
				fmt.Println("OK - FFmpeg disponível")
				os.Exit(0)
			} else {
				fmt.Println("ERROR - FFmpeg não encontrado")
				os.Exit(1)
			}
		},
	}

	rootCmd.AddCommand(healthCmd)

	if err := rootCmd.Execute(); err != nil {
		log.Fatal(err)
	}
}

func runConversion() {
	if !checkFFmpeg() {
		log.Fatal("FFmpeg não está disponível")
	}

	if verbose {
		fmt.Printf("🎬 Rota42 Video Converter iniciado\n")
		fmt.Printf("📁 Input: %s\n", inputDir)
		fmt.Printf("📁 Output: %s\n", outputDir)
		fmt.Printf("🎯 Format: %s\n", format)
		fmt.Printf("⚡ Quality: %s\n", quality)
		fmt.Printf("👥 Workers: %d\n", workers)
	}

	// Criar diretórios se não existirem
	os.MkdirAll(outputDir, 0755)

	if inputFile != "" && outputFile != "" {
		// Converter arquivo específico
		convertVideo(inputFile, outputFile)
	} else {
		// Converter todos os vídeos do diretório
		convertAllVideos()
	}
}

func runWatchMode() {
	fmt.Println("🔍 Modo de monitoramento ativo...")
	fmt.Printf("📁 Monitorando: %s\n", inputDir)
	
	for {
		time.Sleep(5 * time.Second)
		if autoConvert {
			convertAllVideos()
		}
	}
}

func convertAllVideos() {
	videoExtensions := []string{".mp4", ".avi", ".mov", ".mkv", ".wmv", ".flv", ".webm"}
	
	err := filepath.Walk(inputDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if info.IsDir() {
			return nil
		}

		ext := strings.ToLower(filepath.Ext(path))
		for _, validExt := range videoExtensions {
			if ext == validExt {
				outputPath := generateOutputPath(path)
				convertVideo(path, outputPath)
				break
			}
		}
		return nil
	})

	if err != nil {
		log.Printf("Erro ao processar diretório: %v", err)
	}
}

func convertVideo(inputPath, outputPath string) {
	if verbose {
		fmt.Printf("🔄 Convertendo: %s -> %s\n", inputPath, outputPath)
	}

	// Verificar se arquivo de saída já existe
	if _, err := os.Stat(outputPath); err == nil {
		if verbose {
			fmt.Printf("⏭️  Pulando (já existe): %s\n", outputPath)
		}
		return
	}

	// Preparar comando FFmpeg baseado na qualidade
	args := buildFFmpegArgs(inputPath, outputPath)
	
	start := time.Now()
	cmd := exec.Command("ffmpeg", args...)
	
	if verbose {
		fmt.Printf("🚀 Executando: ffmpeg %s\n", strings.Join(args, " "))
	}
	
	err := cmd.Run()
	duration := time.Since(start)
	
	if err != nil {
		log.Printf("❌ Erro na conversão: %v", err)
		return
	}

	if verbose {
		fmt.Printf("✅ Conversão concluída em %v: %s\n", duration, outputPath)
	}
}

func buildFFmpegArgs(inputPath, outputPath string) []string {
	args := []string{"-i", inputPath}
	
	// Configurações baseadas na qualidade
	switch quality {
	case "low":
		args = append(args, "-crf", "28", "-preset", "fast")
	case "high":
		args = append(args, "-crf", "18", "-preset", "slow")
	default: // medium
		args = append(args, "-crf", "23", "-preset", "medium")
	}
	
	// Codec e formato
	args = append(args, "-c:v", "libx264", "-c:a", "aac")
	args = append(args, "-y") // Sobrescrever se existir
	args = append(args, outputPath)
	
	return args
}

func generateOutputPath(inputPath string) string {
	filename := filepath.Base(inputPath)
	nameWithoutExt := strings.TrimSuffix(filename, filepath.Ext(filename))
	newFilename := fmt.Sprintf("%s_converted.%s", nameWithoutExt, format)
	return filepath.Join(outputDir, newFilename)
}

func checkFFmpeg() bool {
	cmd := exec.Command("ffmpeg", "-version")
	err := cmd.Run()
	return err == nil
}
