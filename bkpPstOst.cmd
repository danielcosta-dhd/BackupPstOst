@echo off
title Backup de Arquivos OST/PST
color 1F
chcp 1252 >nul
cls

setlocal enabledelayedexpansion

:: Configurações
set "DESTINO_BASE=\\servidor\caminho\para\backup\ 
:: Verifica se o destino base existe
if not exist "%DESTINO_BASE%" (
    echo ERRO: Pasta destino nao encontrada: %DESTINO_BASE%
    pause
    exit /b 1
)

echo ==============================================
echo Backup de arquivos .OST e .PST dos usuarios
echo ==============================================
echo.

:: Percorre as pastas de usuários (começando com x ou m)
for /d %%i in (C:\Users\x* C:\Users\m*) do (
    call :ProcessarUsuario "%%~ni" "%%~fi"
)

echo.
echo ==============================================
echo Processo concluido!
echo ==============================================
pause
goto :fim

:: ------------------------------------------------------------
:: Função para processar cada usuário
:: ------------------------------------------------------------
:ProcessarUsuario
set "usuario=%~1"
set "caminho_usuario=%~2"
set "destino_usuario=%DESTINO_BASE%\%usuario%"

echo [INFO] Processando usuario: %usuario%
echo [INFO] Caminho de origem: %caminho_usuario%

:: Cria a pasta de destino para este usuário, se não existir
if not exist "%destino_usuario%" (
    mkdir "%destino_usuario%" 2>nul
    if errorlevel 1 (
        echo [ERRO] Nao foi possivel criar a pasta %destino_usuario%
        echo.
        goto :eof
    )
)

:: Procura recursivamente por arquivos .ost e .pst
set "arquivos_encontrados=0"
for /r "%caminho_usuario%" %%a in (*.ost *.pst) do (
    set "arquivos_encontrados=1"
    echo   - Arquivo encontrado: %%~nxa
    echo     Origem: %%a
    echo     Destino: %destino_usuario%\%%~nxa

    :: Copia apenas se o arquivo não existir no destino
    if not exist "%destino_usuario%\%%~nxa" (
        echo     Copiando...
        xcopy /y /v /h /f /j "%%a" "%destino_usuario%\" >nul
        if errorlevel 1 (
            echo     [ERRO] Falha ao copiar %%~nxa
        ) else (
            echo     [OK] Copiado com sucesso!
        )
    ) else (
        echo     [IGNORADO] Arquivo ja existe no destino.
    )
    echo.
)

if "%arquivos_encontrados%" equ "0" (
    echo [INFO] Nenhum arquivo .OST ou .PST encontrado para %usuario%
)

echo -------------------------------------------------
goto :eof

:: ------------------------------------------------------------
:fim
endlocal
