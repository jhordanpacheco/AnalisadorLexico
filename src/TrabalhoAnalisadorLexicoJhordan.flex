/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * Tradutores - UNISINOS - 2022/2                                          *
 * Analisador Lexico                                                       *
 * Jhordan Pacheco                                                         *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.io.FileWriter;
import java.io.IOException;

%%

%public
%class AnalisadorLexico
%standalone

%unicode

%{
    static String textoOutput = "";

    static boolean anterior_mesmo_tipo;

	static int escopo = 0;
	static int contadorIdentificador = 0;

    static Map<String, Integer> identificadores = new HashMap<String, Integer>();
	static Map<String, Integer> escopoIdentificador = new HashMap<String, Integer>();

	private String obterTextoFormatado(String texto) {
		String removerAspas = texto.replaceAll("\"", "");

		return removerAspas.replaceAll("\\s+", " ");
	}

	private static void fecharEscopo(int escopo) {
		for(String key: escopoIdentificador.keySet()) {
			if(escopoIdentificador.get(key).equals(escopo)) {
				identificadores.remove(key);
			}
		}

		escopoIdentificador.values().removeIf(val -> val.equals(escopo));
	}

	private void escreverOutroCaractere(String valor) {
		switch(valor){
			case "=":
				System.out.println("[equal, " + yytext() + "]");
                textoOutput += "[equal," + yytext() +"]\n";
				break;

			case "(":
				escopo++;
				System.out.println("[l_paren, " + yytext() + "]");
                textoOutput += "[l_paren," + yytext() +"]\n";
				break;

			case ")":
				escopo--;
				System.out.println("[r_paren, " + yytext() + "]");
                textoOutput += "[r_paren," + yytext() +"]\n";
				break;

			case "[":
				System.out.println("[l_bracket, " + yytext() + "]");
                textoOutput += "[l_bracket," + yytext() +"]\n";
				break;

			case "]":
				System.out.println("[r_bracket, " + yytext() + "]");
                textoOutput += "[r_bracket," + yytext() +"]\n";
				break;

			case "{":
			escopo++;
				System.out.println("[l_braces, " + yytext() + "]");
                textoOutput += "[l_braces," + yytext() +"]\n";
				break;

			case "}":
				fecharEscopo(escopo);
				escopo--;
				System.out.println("[r_braces, " + yytext() + "]");
                textoOutput += "[r_braces," + yytext() +"]\n";
				break;

			case ",":
				System.out.println("[comma, " + yytext() + "]");
                textoOutput += "[comma," + yytext() +"]\n";
				break;

			case ";":
				System.out.println("[semicolon, " + yytext() + "]");
                textoOutput += "[semicolon," + yytext() +"]\n";
				break;
		}
	}

    private static void imprimirIdentificador(String palavra) {
		String escopoVariavel = palavra;

		if(anterior_mesmo_tipo){
			contadorIdentificador++;

			if(escopo > 0) {
				escopoVariavel.concat(Integer.toString(escopo));
			}

			identificadores.put(escopoVariavel, contadorIdentificador);
			escopoIdentificador.put(palavra, escopo);

            System.out.printf("[Id, %s]\n", contadorIdentificador);
			textoOutput += "[Id," + String.valueOf(contadorIdentificador)+"]\n";
		} else {
			int escopoEncontrado = escopo;

            while(escopoEncontrado > 0) {
				for(String key: escopoIdentificador.keySet()) {
					if(key.equals(palavra) && escopoIdentificador.get(key).equals(escopoEncontrado)) {
						escopoVariavel.concat(Integer.toString(escopoEncontrado));

                        escopoEncontrado = 0;
					}
				}

				escopoEncontrado--;
			}

			if (identificadores.get(escopoVariavel) == null) {
				contadorIdentificador++;

                identificadores.put(palavra, contadorIdentificador);
				escopoIdentificador.put(palavra, escopo);

                System.out.printf("[Id, %s ]\n", contadorIdentificador);
				textoOutput += "[Id," + String.valueOf(contadorIdentificador)+"]\n";
			} else {
				 System.out.printf("[Id, %s]\n", identificadores.get(escopoVariavel));

				 int identificadoresGet = identificadores.get(escopoVariavel);
				 textoOutput += "[Id," + String.valueOf(identificadoresGet)+"]\n";
			}
		}
	}
%}

LineTerminator = \r|\n|\r\n
WhiteSpace = {LineTerminator} | [ \t\f]
InputCharacter = [^\r\n]

TraditionalComment = "/*" [^*] ~"*/" | "/*" "*"+ "/"
EndOfLineComment = "//" {InputCharacter}* {LineTerminator}?
Comment = {TraditionalComment} | {EndOfLineComment}

Includes = "#include <stdio.h>" | "#include <conio.h>"

Condition = "if"|"else"|"switch"|"case"
Loop = "do"|"while"|"for"|"break"
Type = "int"|"float"|"double"|"string"|"bool"|"void"
NullType = "null"|"NULL"
OtherReservedWord = "return"
ReservedWord = {Condition} | {Loop} | {NullType} | {OtherReservedWord}

OtherCharacteres = "="|"("|")"|"{"|"}"|"["|"]"|","|";"|"."

RelationalOperator = "<"|"<="|"=="|"!="|">="|">"

LogicalOperator = "&&"|"||"

ArithmeticOperator = "+"|"-"|"*"|"/"|"%"

OtherOperator = "&"

Digit = [0-9]
Id = [a-zA-Z][a-zA-Z0-9]*
String = (\"[^\"]*\")

%%

/* integers */
{Digit}+ { System.out.println("[num, " + yytext() + "]"); anterior_mesmo_tipo = false; }

/* floats */
{Digit}+"."{Digit}+ { System.out.println("[num, " + yytext() + "]"); anterior_mesmo_tipo = false; }

/* palavras reservadas */
{ReservedWord} { System.out.println("[reserved_word, " + yytext() + "]"); anterior_mesmo_tipo = false; }
{Type} { System.out.println("[reserved_word, " + yytext() + "]"); anterior_mesmo_tipo = true; }

/* outros caracteres */
{OtherCharacteres} { escreverOutroCaractere(yytext()); anterior_mesmo_tipo = false; }

/* operadores relacionais */
{RelationalOperator} { System.out.println("[relational_operator, " + yytext() + "]"); anterior_mesmo_tipo = false; }

/* operadores logicos */
{LogicalOperator} { System.out.println("[logical_operator, " + yytext() + "]"); anterior_mesmo_tipo = false; }

/* operadores aritmeticos */
{ArithmeticOperator} { System.out.println("[arithmetic_operator, " + yytext() + "]"); anterior_mesmo_tipo = false; }

/* outros operadores */
{OtherOperator} { System.out.println("[operator, " + yytext() + "]"); anterior_mesmo_tipo = false; }

/* strings */
{String} { System.out.println("[string_literal, " + obterTextoFormatado(yytext()) + "]"); anterior_mesmo_tipo = false; }

/* identificadores */
{Id} { imprimirIdentificador(yytext()); anterior_mesmo_tipo = false; }

{WhiteSpace} { /* ignore */ }
{Comment} { /* ignore */ }
{Includes} { /* ignore */ }

/* error fallback */
[^] { System.out.println("Illegal character <" + yytext() + ">"); }