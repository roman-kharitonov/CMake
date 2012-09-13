/*============================================================================
  CMake - Cross Platform Makefile Generator
  Copyright 2012 Stephen Kelly <steveire@gmail.com>

  Distributed under the OSI-approved BSD License (the "License");
  see accompanying file Copyright.txt for details.

  This software is distributed WITHOUT ANY WARRANTY; without even the
  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the License for more information.
============================================================================*/
#ifndef cmGeneratorExpressionEvaluator_h
#define cmGeneratorExpressionEvaluator_h

#include <vector>
#include <string>

//----------------------------------------------------------------------------
struct cmGeneratorExpressionContext
{
  cmListFileBacktrace Backtrace;
  std::set<cmTarget*> Targets;
  cmMakefile *Makefile;
  const char *Config;
  cmTarget *Target;
  bool Quiet;
  bool HadError;
};

//----------------------------------------------------------------------------
struct cmGeneratorExpressionEvaluator
{
  virtual ~cmGeneratorExpressionEvaluator() {}

  enum Type
  {
    Text,
    Generator
  };

  virtual Type GetType() const = 0;

  virtual std::string Evaluate(cmGeneratorExpressionContext *context
                              ) const = 0;
};

struct TextContent : public cmGeneratorExpressionEvaluator
{
  TextContent(const char *start, uint length)
    : Content(start), Length(length)
  {

  }

  std::string Evaluate(cmGeneratorExpressionContext *) const
  {
    return std::string(this->Content, this->Length);
  }

  Type GetType() const
  {
    return cmGeneratorExpressionEvaluator::Text;
  }

  void Extend(uint length)
  {
    this->Length += length;
  }

  uint GetLength()
  {
    return this->Length;
  }

private:
  const char *Content;
  uint Length;
};

//----------------------------------------------------------------------------
struct GeneratorExpressionContent : public cmGeneratorExpressionEvaluator
{
  GeneratorExpressionContent(const char *startContent, uint length);
  void SetIdentifier(std::vector<cmGeneratorExpressionEvaluator*> identifier)
  {
    this->IdentifierChildren = identifier;
  }

  void SetParameters(
        std::vector<std::vector<cmGeneratorExpressionEvaluator*> > parameters)
  {
    this->ParamChildren = parameters;
  }

  Type GetType() const
  {
    return cmGeneratorExpressionEvaluator::Generator;
  }

  std::string Evaluate(cmGeneratorExpressionContext *context) const;

  std::string GetOriginalExpression() const;

private:
  std::vector<cmGeneratorExpressionEvaluator*> IdentifierChildren;
  std::vector<std::vector<cmGeneratorExpressionEvaluator*> > ParamChildren;
  const char *StartContent;
  uint ContentLength;
};

#endif